import UIKit
import FirebaseAuth

// Centralized palette: icon coral for emphasis, darker/lighter variants for readable controls.
enum KirokunTheme {
    static let brand = UIColor(red: 1, green: 88/255, blue: 87/255, alpha: 1)
    static let action = UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 1, green: 0.55, blue: 0.54, alpha: 1) : UIColor(red: 0.72, green: 0.14, blue: 0.20, alpha: 1) }
    static func styleControls(primary: UIButton, secondary: UIButton, icon: UIImageView?, symbol: String?) {
        primary.setTitleColor(.black, for: .normal)
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
            icon.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .medium))
            icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
            icon.tintColor = action
            icon.backgroundColor = brand.withAlphaComponent(0.12)
            icon.contentMode = .center
            icon.layer.cornerRadius = 50
            icon.layer.shadowOpacity = 0
            icon.isAccessibilityElement = false
        }
    }
    static let answeredText = UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.72, alpha: 1) : UIColor(white: 0.38, alpha: 1) }
    static func rowBackground(_ index: Int) -> UIColor {
        index.isMultiple(of: 2) ? .systemBackground : UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(red: 0.18, green: 0.12, blue: 0.13, alpha: 1) : UIColor(red: 1, green: 0.94, blue: 0.94, alpha: 1)
        }
    }
    static func styleModalHeader(_ header: UIView) {
        header.backgroundColor = brand
        header.subviews.compactMap { $0 as? UILabel }.forEach { $0.textColor = .black }
        header.subviews.compactMap { $0 as? UIButton }.forEach {
            var config = UIButton.Configuration.plain()
            if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled { config = .glass() }
            $0.setImage(nil, for: .normal)
            config.image = UIImage(systemName: "xmark")
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            config.baseForegroundColor = .black
            $0.configuration = config
            $0.accessibilityLabel = NSLocalizedString("close", comment: "")
        }
    }
    static func styleQuestion(_ controller: UIViewController) {
        if controller.view.viewWithTag(74001) == nil {
            let banner = UILabel(); banner.tag = 74001
            banner.text = KirokunProject.name
            banner.font = .preferredFont(forTextStyle: .headline)
            banner.textAlignment = .center; banner.textColor = .black; banner.backgroundColor = brand
            banner.translatesAutoresizingMaskIntoConstraints = false
            controller.view.addSubview(banner)
            NSLayoutConstraint.activate([
                banner.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor),
                banner.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                banner.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                banner.heightAnchor.constraint(equalToConstant: 52)
            ])
        }
        switch controller {
        case let c as HeaderViewController:
            c.subTitleLabel.textColor = action
            styleControls(primary: c.nextButton, secondary: c.closeButton, icon: nil, symbol: nil)
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
