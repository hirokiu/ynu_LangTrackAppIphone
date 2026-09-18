import UIKit
import FirebaseAuth

// Centralized palette: icon coral for emphasis, darker/lighter variants for readable controls.
enum KirokunTheme {
    static let brand = UIColor(red: 1, green: 88/255, blue: 87/255, alpha: 1)
    // Filled surfaces follow the original KIROKUN icon color.
    static let filledBackground = brand
    static let onFilled = UIColor.white
    static let action = UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 1, green: 0.55, blue: 0.54, alpha: 1) : UIColor(red: 0.72, green: 0.14, blue: 0.20, alpha: 1) }
    static func styleControls(primary: UIButton, secondary: UIButton, icon: UIImageView?, symbol: String?) {
        primary.setTitleColor(onFilled, for: .normal)
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
    static func commonHeader() -> UILabel {
        let label = UILabel()
        label.text = "KIROKUN"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = action; label.backgroundColor = .systemBackground
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    static func inputDescription(for type: String) -> String {
        NSLocalizedString("input_mode_" + type, comment: "Actual input behavior")
    }
    static func styleOverviewIcons(in view: UIView, type: String) {
        for child in view.subviews {
            if let icon = child as? UIImageView {
                if type == "header" {
                    icon.isHidden = true
                    icon.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = 0 }
                } else {
                    let symbols = ["open":"text.alignleft", "likert":"slider.horizontal.3", "multi":"checklist", "single":"list.bullet.circle", "blanks":"text.insert", "slider":"slider.horizontal.3", "duration":"clock"]
                    icon.image = UIImage(systemName: symbols[type] ?? "checkmark.circle")
                    icon.tintColor = action; icon.contentMode = .scaleAspectFit
                    icon.backgroundColor = .clear; icon.layer.shadowOpacity = 0
                }
            }
            styleOverviewIcons(in: child, type: type)
        }
    }
    static func setLabelColor(in view: UIView, color: UIColor) {
        for child in view.subviews {
            (child as? UILabel)?.textColor = color
            setLabelColor(in: child, color: color)
        }
    }
    static func alignMetadataValues(_ values: [UILabel], in container: UIView) {
        let links = container.constraints.filter { constraint in
            constraint.firstAttribute == .leading && values.contains { constraint.firstItem as? UILabel === $0 } && constraint.secondItem is UILabel
        }
        let keys = links.compactMap { $0.secondItem as? UILabel }
        guard let first = values.first, let widest = keys.max(by: { $0.intrinsicContentSize.width < $1.intrinsicContentSize.width }) else { return }
        NSLayoutConstraint.deactivate(links)
        first.leadingAnchor.constraint(equalTo: widest.trailingAnchor, constant: 15).isActive = true
        for value in values {
            value.textAlignment = .left
            value.numberOfLines = 0
            if value !== first { value.leadingAnchor.constraint(equalTo: first.leadingAnchor).isActive = true }
        }
    }
    static func styleModalHeader(_ header: UIView) {
        header.backgroundColor = filledBackground
        setLabelColor(in: header, color: onFilled)
        header.subviews.compactMap { $0 as? UIButton }.forEach {
            var config = UIButton.Configuration.plain()
            if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled { config = .glass() }
            $0.setImage(nil, for: .normal)
            config.image = UIImage(systemName: "xmark")
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            config.baseForegroundColor = onFilled
            $0.configuration = config
            $0.accessibilityLabel = NSLocalizedString("close", comment: "")
        }
    }
    static func styleQuestion(_ controller: UIViewController) {
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
        var attributes = AttributeContainer()
        attributes.foregroundColor = onFilled
        config.attributedTitle = AttributedString(title, attributes: attributes)
        config.baseBackgroundColor = filledBackground
        config.baseForegroundColor = onFilled
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes; updated.foregroundColor = onFilled; return updated
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
