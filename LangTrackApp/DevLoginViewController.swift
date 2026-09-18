#if KIROKUN_DEV
import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class DevSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = DevLoginViewController()
        window?.makeKeyAndVisible()
        for context in options.urlContexts { GIDSignIn.sharedInstance.handle(context.url) }
    }
    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        for context in contexts { GIDSignIn.sharedInstance.handle(context.url) }
    }
}

class DevLoginViewController: UIViewController {
    private let status = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let signInButton = GIDSignInButton()
    private let signOutButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)
    private var generation = 0
    private func text(_ key: String) -> String { NSLocalizedString(key, comment: "Dev authentication") }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let title = UILabel(); title.text = "KIROKUN Dev"; title.font = .preferredFont(forTextStyle: .largeTitle)
        status.numberOfLines = 0; status.text = text("dev_login_intro")
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        signOutButton.setTitle(text("dev_sign_out"), for: .normal)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        retryButton.setTitle(text("dev_retry_connection"), for: .normal)
        retryButton.addTarget(self, action: #selector(checkConnection), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [title, status, signInButton, retryButton, signOutButton, spinner])
        stack.axis = .vertical; stack.spacing = 24; stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24), stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24), stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48)])
        render(busy: false)
        if Auth.auth().currentUser != nil { checkConnection() }
    }
    private func render(busy: Bool) {
        signInButton.isEnabled = !busy
        retryButton.isEnabled = !busy
        signOutButton.isEnabled = !busy
        let signedIn = Auth.auth().currentUser != nil
        signInButton.isHidden = signedIn
        retryButton.isHidden = !signedIn
        signOutButton.isHidden = !signedIn
        busy ? spinner.startAnimating() : spinner.stopAnimating()
    }
    @objc private func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        render(busy: true)
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            guard let user = result?.user, let token = user.idToken?.tokenString, error == nil else {
                self.reportAuthError(error, stage: "dev_google_failed"); return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { [weak self] _, error in
                guard let self = self else { return }
                if let error = error { self.reportAuthError(error, stage: "dev_firebase_failed"); return }
                self.checkConnection()
            }
        }
    }
    private func reportAuthError(_ error: Error?, stage: String) {
        let nsError = error as NSError?
        // Log codes only: userInfo and descriptions may contain credentials or personal data.
        NSLog("Dev authentication stage=%@ domain=%@ code=%ld", stage, nsError?.domain ?? "unknown", nsError?.code ?? 0)
        let cancelled = nsError?.domain == "com.google.GIDSignIn" && nsError?.code == -5
        status.text = cancelled ? text("dev_login_cancelled") : text(stage) + "\n" + String(nsError?.code ?? 0)
        render(busy: false)
    }
    @objc private func signOut() {
        generation += 1
        do { try Auth.auth().signOut() } catch { status.text = text("dev_login_failed"); return }
        GIDSignIn.sharedInstance.signOut()
        status.text = text("dev_login_intro"); render(busy: false)
    }
    @objc private func checkConnection() {
        guard let user = Auth.auth().currentUser else { return }
        generation += 1; let requestGeneration = generation
        render(busy: true); status.text = text("dev_connecting")
        user.getIDTokenForcingRefresh(true) { [weak self] token, error in
            guard let self = self, self.generation == requestGeneration else { return }
            guard let token = token, error == nil,
                  let base = Bundle.main.object(forInfoDictionaryKey: "KIROKUN_API_BASE_URL") as? String,
                  let url = URL(string: base + "admin/surveys?page=1&limit=10") else {
                self.status.text = self.text("dev_login_failed"); self.render(busy: false); return
            }
            var request = URLRequest(url: url); request.timeoutInterval = 15
            request.setValue(token, forHTTPHeaderField: "token")
            // This endpoint checks the server-side UID allowlist. No email-derived identity or writes.
            let session = URLSession(configuration: .ephemeral, delegate: NoRedirectDelegate(), delegateQueue: nil)
            session.dataTask(with: request) { [weak self] data, response, error in
                defer { session.finishTasksAndInvalidate() }
                DispatchQueue.main.async {
                    guard let self = self, self.generation == requestGeneration else { return }
                    let code = (response as? HTTPURLResponse)?.statusCode
                    let object = data.flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
                    let validJSON = object?["items"] is [Any]
                    let key = error == nil && code == 200 && validJSON ? "dev_connected" : ((code == 401 || code == 403) ? "dev_not_authorized" : "dev_connection_failed")
                    self.status.text = self.text(key); self.render(busy: false)
                }
            }.resume()
        }
    }
}
private class NoRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) { completionHandler(nil) }
}
#endif
