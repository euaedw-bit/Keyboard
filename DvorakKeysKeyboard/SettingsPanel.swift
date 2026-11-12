import UIKit

/// Painel de ajustes dentro do próprio teclado (abre segurando o "123" por 3 segundos).
final class SettingsPanel: UIView {
    var onClose: (() -> Void)?
    var onChange: (() -> Void)?
    var onSwitchKeyboard: (() -> Void)?

    private let settings = Settings.shared
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private var titleLabels: [UILabel] = []
    private var palette: Palette

    init(palette: Palette, showSwitchKeyboard: Bool) {
        self.palette = palette
        super.init(frame: .zero)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)

        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -32)
        ])

        buildContent(showSwitchKeyboard: showSwitchKeyboard)
        apply(palette: palette)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Conteúdo

    private func title(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabels.append(l)
        return l
    }

    private func row(_ text: String, control: UIView) -> UIStackView {
        let h = UIStackView(arrangedSubviews: [title(text), control])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 8
        return h
    }

    private func buildContent(showSwitchKeyboard: Bool) {
        // Cabeçalho
        let header = title("Ajustes")
        header.font = .systemFont(ofSize: 20, weight: .bold)
        let close = UIButton(type: .system)
        close.setTitle("Fechar", for: .normal)
        close.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        let head = UIStackView(arrangedSubviews: [header, UIView(), close])
        head.axis = .horizontal
        head.alignment = .center
        stack.addArrangedSubview(head)

        // Tamanho das teclas
        let size = UISlider()
        size.minimumValue = 0.85
        size.maximumValue = 1.40
        size.value = Float(settings.keyScale)
        size.addTarget(self, action: #selector(sizeChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(title("Tamanho das teclas"))
        stack.addArrangedSubview(size)

        // Tema
        let theme = UISegmentedControl(items: ["Automático", "Escuro", "Claro"])
        theme.selectedSegmentIndex = settings.themeMode.rawValue
        theme.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(title("Tema"))
        stack.addArrangedSubview(theme)

        // Degradê
        let grad = UISegmentedControl(items: Theme.presetNames)
        grad.selectedSegmentIndex = settings.gradientIndex
        grad.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11)], for: .normal)
        grad.addTarget(self, action: #selector(gradientChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(title("Degradê de fundo"))
        stack.addArrangedSubview(grad)

        // Estilo das teclas
        let styleSeg = UISegmentedControl(items: ["Vidro (Liquid Glass)", "Fosco (leve)"])
        styleSeg.selectedSegmentIndex = settings.keyStyle.rawValue
        styleSeg.addTarget(self, action: #selector(styleChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(title("Estilo das teclas"))
        stack.addArrangedSubview(styleSeg)

        // Arrasto
        let swipe = UISlider()
        swipe.minimumValue = 70
        swipe.maximumValue = 240
        swipe.value = Float(settings.wordSwipeDistance)
        swipe.addTarget(self, action: #selector(swipeChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(title("Arrasto para apagar palavra (distância)"))
        stack.addArrangedSubview(swipe)

        // Switches
        let hap = UISwitch()
        hap.isOn = settings.haptics
        hap.addTarget(self, action: #selector(hapticsChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(row("Vibração (haptic)", control: hap))

        let sug = UISwitch()
        sug.isOn = settings.suggestions
        sug.addTarget(self, action: #selector(suggestionsChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(row("Sugestões de palavras", control: sug))

        let auto = UISwitch()
        auto.isOn = settings.autocorrect
        auto.addTarget(self, action: #selector(autocorrectChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(row("Autocorreção", control: auto))

        if showSwitchKeyboard {
            let b = UIButton(type: .system)
            b.setTitle("🌐  Trocar de teclado", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            b.addTarget(self, action: #selector(switchTapped), for: .touchUpInside)
            stack.addArrangedSubview(b)
        }

        let tip = UILabel()
        tip.text = "Dica: segure o botão 123 por 3 segundos para abrir estes ajustes."
        tip.font = .systemFont(ofSize: 12)
        tip.numberOfLines = 0
        titleLabels.append(tip)
        stack.addArrangedSubview(tip)
    }

    func apply(palette: Palette) {
        self.palette = palette
        backgroundColor = palette.popupBg
        for l in titleLabels { l.textColor = palette.text }
        tintColor = palette.accent
    }

    // MARK: Ações

    @objc private func closeTapped() { onClose?() }
    @objc private func switchTapped() { onSwitchKeyboard?() }

    @objc private func sizeChanged(_ s: UISlider) {
        settings.keyScale = CGFloat((s.value * 20).rounded() / 20)
        onChange?()
    }

    @objc private func themeChanged(_ s: UISegmentedControl) {
        settings.themeMode = ThemeMode(rawValue: s.selectedSegmentIndex) ?? .auto
        onChange?()
    }

    @objc private func gradientChanged(_ s: UISegmentedControl) {
        settings.gradientIndex = s.selectedSegmentIndex
        onChange?()
    }

    @objc private func styleChanged(_ s: UISegmentedControl) {
        settings.keyStyle = KeyStyle(rawValue: s.selectedSegmentIndex) ?? .glass
        onChange?()
    }

    @objc private func swipeChanged(_ s: UISlider) {
        settings.wordSwipeDistance = CGFloat(s.value.rounded())
    }

    @objc private func hapticsChanged(_ s: UISwitch) { settings.haptics = s.isOn }

    @objc private func suggestionsChanged(_ s: UISwitch) {
        settings.suggestions = s.isOn
        onChange?()
    }

    @objc private func autocorrectChanged(_ s: UISwitch) { settings.autocorrect = s.isOn }
}
