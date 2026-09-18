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
        // Keep the original question illustrations and their placement.
        icon?.isAccessibilityElement = false
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

// Project availability is deliberately scoped to the installed app's Firebase environment.
// Add projects only together with their authentication and API routing configuration.
enum KirokunProject {
    static var name: String {
        #if KIROKUN_DEV
        return "Dev"
        #else
        return "Proto"
        #endif
    }
    static var connectionTitle: String {
        String(format: NSLocalizedString("project_connected_format", comment: ""), name)
    }
    static func selector(title: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.bordered()
        if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled { config = .glass() }
        config.title = title ?? String(format: NSLocalizedString("project_selection_format", comment: ""), name)
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing; config.imagePadding = 8
        config.baseForegroundColor = KirokunTheme.action
        button.configuration = config
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(title: NSLocalizedString("project_available", comment: ""), children: [
            UIAction(title: name, state: .on) { _ in /* Already selected; retain the current session. */ }
        ])
        button.accessibilityValue = name
        return button
    }
}
