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
        window?.rootViewController = UINavigationController(rootViewController: DevLoginViewController())
        #if DEBUG && targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("--layout-preview") {
            let survey = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "surveyContainer") as! SurveyViewController
            survey.theAssignment = Self.layoutFixture()
            window?.rootViewController = survey
            if ProcessInfo.processInfo.arguments.contains("--preview-unanswered") {
                SurveyRepository.selectedAssignment = Self.layoutFixture()
                window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "unansweredPopup")
            } else if ProcessInfo.processInfo.arguments.contains("--preview-answered") {
                let overview = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "answeredPreview") as! OverviewViewController
                var fixture = Self.layoutFixture()
                let dataset = Dataset(); dataset.createdAt = fixture.published
                dataset.answers = [Answer(type: "open", index: 1, openEndedAnswer: "確認用の回答です。"), Answer(type: "likert", index: 2, likertAnswer: 2)]
                fixture.dataset = dataset; overview.theAssignment = fixture
                window?.rootViewController = overview
            }
        }
        #endif
        window?.tintColor = KirokunTheme.action
        window?.makeKeyAndVisible()
        KirokunTheme.showLaunchArtwork(in: window)
        #if DEBUG && targetEnvironment(simulator)
        if let survey = window?.rootViewController as? SurveyViewController,
           let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--preview-page=") }),
           let index = Int(argument.replacingOccurrences(of: "--preview-page=", with: "")),
           let question = survey.theAssignment?.survey.questions.first(where: { $0.index == index }) {
            survey.view.layoutIfNeeded()
            survey.showPage(newPage: question)
        }
        #endif
        for context in options.urlContexts { GIDSignIn.sharedInstance.handle(context.url) }
    }
    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        for context in contexts { GIDSignIn.sharedInstance.handle(context.url) }
    }
}

#if DEBUG && targetEnvironment(simulator)
extension DevSceneDelegate {
    static func layoutFixture() -> Assignment {
        var assignment = Assignment()
        assignment.id = "local-layout-preview"
        assignment.published = "2026-09-18T00:00:00.000Z"
        assignment.expiry = "2099-10-02T00:00:00.000Z"
        assignment.survey.title = "画面サイズ確認用アンケート（端末内のみ）"
        let types = ["header", "open", "likert", "single", "multi", "blanks", "slider", "duration", "footer"]
        let texts = ["7種類の入力形式を確認します。回答はサーバーへ送信されません。", "今日の学習で気づいたことや、難しかったことを自由に入力してください。", "今日の学習に満足していますか？", "今日もっとも使った言語を選んでください。", "今日行った活動をすべて選んでください。", "今日は _____ を学びました。", "今日の学習の集中度を教えてください。", "今日の学習時間を入力してください。", "回答内容の確認"]
        assignment.survey.questions = types.enumerated().map { index, type in
            let q = Question(); q.type = type; q.index = index; q.previous = max(0, index - 1); q.next = min(8, index + 1)
            q.text = texts[index]; q.title = "端末内の表示テスト"
            q.likertMin = "まったく満足していない"; q.likertMax = "とても満足している"
            q.singleMultipleAnswers = ["日本語", "英語", "その他の言語（複数の言語を組み合わせた場合を含みます）"]
            q.multipleChoisesAnswers = ["読む", "聞く", "話す", "書く"]
            q.fillBlanksChoises = ["単語", "文法", "発音"]
            return q
        }
        return assignment
    }
}
#endif

class DevLoginViewController: UIViewController {
    private let status = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let signInButton = GIDSignInButton()
    private let signOutButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)
    private var generation = 0
    private let surveysButton = UIButton(type: .system)
    private func text(_ key: String) -> String { NSLocalizedString(key, comment: "Dev authentication") }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "KIROKUN Dev"
        surveysButton.configuration = KirokunTheme.primaryButton(title: text("dev_open_surveys"))
        surveysButton.addTarget(self, action: #selector(openSurveys), for: .touchUpInside)
        surveysButton.isHidden = true
        let title = UILabel(); title.text = "KIROKUN Dev"; title.font = .preferredFont(forTextStyle: .largeTitle)
        status.font = .preferredFont(forTextStyle: .body); status.adjustsFontForContentSizeCategory = true; status.numberOfLines = 0; status.text = text("dev_login_intro")
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        signOutButton.setTitle(text("dev_sign_out"), for: .normal)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        retryButton.setTitle(text("dev_retry_connection"), for: .normal)
        retryButton.addTarget(self, action: #selector(checkConnection), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [title, KirokunProject.selector(), status, signInButton, surveysButton, retryButton, signOutButton, spinner])
        stack.axis = .vertical; stack.spacing = 24; stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24), stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24), stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48)])
        render(busy: false)
        if Auth.auth().currentUser != nil { checkConnection() }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser == nil {
            surveysButton.isHidden = true
            status.text = text("dev_login_intro")
        }
        render(busy: false)
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
    @objc private func openSurveys() {
        guard presentedViewController == nil else { return }
        let home = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "main")
        home.modalPresentationStyle = .fullScreen
        home.overrideUserInterfaceStyle = .light
        present(home, animated: true)
    }
    @objc private func signOut() {
        surveysButton.isHidden = true
        SurveyRepository.userId = ""; SurveyRepository.idToken = ""; SurveyRepository.assignmentList = []
        SurveyRepository.selectedAssignment = nil
        generation += 1
        do { try Auth.auth().signOut() } catch { status.text = text("dev_login_failed"); return }
        GIDSignIn.sharedInstance.signOut()
        status.text = text("dev_login_intro"); render(busy: false)
    }
    @objc private func checkConnection() {
        guard let user = Auth.auth().currentUser else { return }
        generation += 1; let requestGeneration = generation
        surveysButton.isHidden = true
        render(busy: true); status.text = text("dev_connecting")
        user.getIDTokenForcingRefresh(true) { [weak self] token, error in
            guard let self = self, self.generation == requestGeneration else { return }
            guard let token = token, error == nil,
                  let base = Bundle.main.object(forInfoDictionaryKey: "KIROKUN_API_BASE_URL") as? String,
                  let url = URL(string: base + "me") else {
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
                    let resolvedId = object?["userId"] as? String
                    let validJSON = !(resolvedId ?? "").isEmpty
                    let key = error == nil && code == 200 && validJSON ? "dev_connected" : ((code == 401 || code == 403) ? "dev_not_authorized" : "dev_connection_failed")
                    if key == "dev_connected", let userId = resolvedId {
                        SurveyRepository.userId = userId
                        SurveyRepository.idToken = token
                        self.surveysButton.isHidden = false
                        self.openSurveys()
                    }
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
