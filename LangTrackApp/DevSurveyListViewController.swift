#if KIROKUN_DEV
import UIKit
import FirebaseAuth

// Centralized palette: icon coral for emphasis, darker/lighter variants for readable controls.
enum KirokunTheme {
    static let brand = UIColor(red: 1, green: 88/255, blue: 87/255, alpha: 1)
    static let action = UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 1, green: 0.55, blue: 0.54, alpha: 1) : UIColor(red: 0.72, green: 0.14, blue: 0.20, alpha: 1) }
    static func styleControls(primary: UIButton, secondary: UIButton, icon: UIImageView?, symbol: String?) {
        primary.backgroundColor = .clear
        primary.configuration = primaryButton(title: primary.currentTitle ?? "")
        secondary.backgroundColor = .clear
        var config = UIButton.Configuration.bordered()
        if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled { config = .glass() }
        config.title = secondary.currentTitle; config.baseForegroundColor = action
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes; updated.foregroundColor = action; return updated
        }
        secondary.configuration = config
        if let icon = icon, let symbol = symbol {
            icon.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .regular))
            icon.contentMode = .scaleAspectFit; icon.tintColor = action
            icon.layer.shadowOpacity = 0
            icon.isAccessibilityElement = false
        }
    }
    static func styleQuestion(_ controller: UIViewController) {
        switch controller {
        case let c as HeaderViewController: styleControls(primary: c.nextButton, secondary: c.closeButton, icon: nil, symbol: nil)
        case let c as FooterViewController: styleControls(primary: c.sendInButton, secondary: c.previousButton, icon: c.theIcon, symbol: "checkmark.circle")
        case let c as OpenEndedTextResponsesViewController:
            styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "text.alignleft")
            c.openTextView.isAccessibilityElement = true
            c.openTextView.accessibilityLabel = c.openTextLabel.text
            c.openTextView.font = .preferredFont(forTextStyle: .body)
            c.openTextView.adjustsFontForContentSizeCategory = true
            c.openTextView.backgroundColor = .secondarySystemGroupedBackground
            c.openTextView.layer.borderColor = UIColor.separator.cgColor
        case let c as LikertScaleViewController: styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "slider.horizontal.3")
        case let c as MultipleChoiceViewController: styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "checklist")
        case let c as SingleMultipleAnswersViewController: styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "list.bullet.circle")
        case let c as SliderScaleViewController: styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "slider.horizontal.3")
        case let c as TimeDurationViewController: styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "clock")
        case let c as FillInTheBlankViewController: styleControls(primary: c.nextButton, secondary: c.previousButton, icon: c.theIcon, symbol: "text.insert")
        default: break
        }
    }
    static func primaryButton(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = brand
        config.baseForegroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes; updated.foregroundColor = .black; return updated
        }
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        return config
    }
}

final class DevSurveyListViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {
    private var assignments: [Assignment] = []
    private var generation = 0
    private var loading = false
    private func text(_ key: String) -> String { NSLocalizedString(key, comment: "Dev survey list") }
    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("Use init()") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = text("dev_surveys")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "survey")
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadSurveys), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadSurveys))
        reloadSurveys()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loading { reloadSurveys() }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { generation += 1 }
    }
    private func showStatus(_ key: String) {
        let label = UILabel(); label.text = text(key); label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true; label.numberOfLines = 0; label.textAlignment = .center
        label.textColor = .secondaryLabel
        tableView.backgroundView = label
    }
    @objc private func reloadSurveys() {
        guard !loading, let user = Auth.auth().currentUser, !SurveyRepository.userId.isEmpty else { return }
        loading = true; generation += 1; let current = generation
        showStatus("dev_loading_surveys")
        navigationItem.rightBarButtonItem?.isEnabled = false
        user.getIDTokenForcingRefresh(false) { [weak self] token, error in
            guard let self = self else { return }
            guard let token = token, error == nil else { self.complete(nil, current); return }
            SurveyRepository.idToken = token
            SurveyRepository.getUrl { base in
                guard let base = base, let id = SurveyRepository.userId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                      let url = URL(string: base + "users/" + id + "/assignments") else { self.complete(nil, current); return }
                var request = URLRequest(url: url); request.timeoutInterval = 20
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                request.setValue(token, forHTTPHeaderField: "token")
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200, let data = data,
                          (try? JSONSerialization.jsonObject(with: data)) is [Any],
                          let items = SurveyRepository.createAssignmentsFromData(data: data) else { self.complete(nil, current); return }
                    for assignment in items {
                        let questions = assignment.survey.questions.sorted { $0.index < $1.index }
                        for (i, question) in questions.enumerated() {
                            question.previous = i == 0 ? 0 : questions[i-1].index
                            question.next = i+1 < questions.count ? questions[i+1].index : 0
                        }
                    }
                    self.complete(items, current)
                }.resume()
            }
        }
    }
    private func complete(_ items: [Assignment]?, _ current: Int) {
        DispatchQueue.main.async {
            guard current == self.generation else { return }
            self.loading = false; self.refreshControl?.endRefreshing(); self.navigationItem.rightBarButtonItem?.isEnabled = true
            guard let items = items else { self.assignments = []; self.tableView.reloadData(); self.showStatus("dev_load_failed"); return }
            self.assignments = items.sorted { a, b in
                let activeA = a.dataset == nil && a.timeLeftToExpiryInMilli() > 0
                let activeB = b.dataset == nil && b.timeLeftToExpiryInMilli() > 0
                return activeA != activeB ? activeA : a.published > b.published
            }
            SurveyRepository.assignmentList = self.assignments
            self.tableView.reloadData()
            self.tableView.backgroundView = nil
            if items.isEmpty { self.showStatus("dev_no_surveys") }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { assignments.count }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { text("dev_test_environment") }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = assignments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "survey", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = item.survey.title.isEmpty ? item.survey.name : item.survey.title
        let ready = item.dataset == nil && item.timeLeftToExpiryInMilli() > 0
        let key = item.dataset != nil ? "dev_answered" : (ready ? "dev_ready" : "dev_expired")
        content.secondaryText = text(key)
        if let expiry = DateParser.getDate(dateString: item.expiry) {
            content.secondaryText! += "\n" + text("dev_deadline") + " " + DateFormatter.localizedString(from: expiry, dateStyle: .medium, timeStyle: .short)
        }
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: item.dataset != nil ? "checkmark.circle" : (ready ? "square.and.pencil" : "clock"))
        content.imageProperties.tintColor = ready ? KirokunTheme.action : .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = ready ? .disclosureIndicator : .none
        cell.selectionStyle = ready ? .default : .none
        cell.accessibilityHint = ready ? text("dev_begin_answer") : text(key)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = assignments[indexPath.row]
        guard !loading, item.dataset == nil, item.timeLeftToExpiryInMilli() > 0 else { return }
        let controller = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "surveyContainer") as! SurveyViewController
        SurveyRepository.selectedAssignment = item
        controller.theAssignment = item
        controller.theUser = User(userName: SurveyRepository.userId, mail: "")
        controller.overrideUserInterfaceStyle = .light // Existing question forms will be redesigned separately.
        controller.onSaved = { [weak self] in
            self?.reloadSurveys()
            let alert = UIAlertController(title: NSLocalizedString("dev_saved", comment: ""), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) { reloadSurveys() }
}
#endif
