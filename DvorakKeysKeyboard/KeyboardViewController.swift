import UIKit

final class KeyboardViewController: UIInputViewController, KeyboardViewDelegate {

    private let settings = Settings.shared
    private let engine = SuggestionEngine()

    private let gradient = CAGradientLayer()
    private let bar = SuggestionBar()
    private let keyboard = KeyboardView()
    private var emojiPanel: EmojiPanel?
    private var settingsPanel: SettingsPanel?
    private var heightConstraint: NSLayoutConstraint?

    private let impact = UIImpactFeedbackGenerator(style: .light)

    private var lang: Lang = .en
    private var shift: ShiftState = .off {
        didSet { keyboard.shiftState = shift }
    }
    private var lastShiftTap = Date.distantPast
    private var shiftSnapshotForUndo: ShiftState = .off

    // Para poder desfazer um toque que virou arrasto/long-press, e a autocorreção.
    private var insertToken = 0
    private var autocorrectUndo: (original: String, corrected: String)?

    private let barHeight: CGFloat = 42
    private let baseRowHeight: CGFloat = 52

    private var proxy: UITextDocumentProxy { textDocumentProxy }

    // MARK: Ciclo de vida

    override func viewDidLoad() {
        super.viewDidLoad()
        lang = settings.language

        view.layer.insertSublayer(gradient, at: 0)

        bar.translatesAutoresizingMaskIntoConstraints = false
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        view.addSubview(keyboard)

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: barHeight),
            keyboard.topAnchor.constraint(equalTo: bar.bottomAnchor),
            keyboard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboard.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        keyboard.delegate = self
        keyboard.lang = lang

        bar.onPick = { [weak self] text in self?.pickSuggestion(text) }

        let h = view.heightAnchor.constraint(equalToConstant: totalHeight())
        h.priority = UILayoutPriority(999)
        h.isActive = true
        heightConstraint = h

        applyTheme()
        updateSuggestions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if settings.themeMode == .auto { applyTheme() }
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        updateSuggestions()
    }

    // MARK: Tema e tamanho

    private func totalHeight() -> CGFloat {
        let rowH = baseRowHeight * settings.keyScale
        return barHeight + 5 * rowH + 4 * 8 + 12
    }

    private func isDark() -> Bool {
        switch settings.themeMode {
        case .dark: return true
        case .light: return false
        case .auto: return traitCollection.userInterfaceStyle == .dark
        }
    }

    private func applyTheme() {
        let palette = Theme.palette(isDark: isDark(), preset: settings.gradientIndex)
        gradient.colors = palette.gradient.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        bar.apply(palette: palette)
        keyboard.apply(palette: palette, style: settings.keyStyle)
        keyboard.shiftState = shift
        emojiPanel?.apply(palette: palette)
        settingsPanel?.apply(palette: palette)
        heightConstraint?.constant = totalHeight()
        updateSuggestions()
    }

    private func currentPalette() -> Palette {
        Theme.palette(isDark: isDark(), preset: settings.gradientIndex)
    }

    // MARK: Texto

    private func bump() { insertToken += 1 }

    func kbInsert(_ text: String) -> Int {
        shiftSnapshotForUndo = shift
        proxy.insertText(text)
        if shift == .once { shift = .off }
        autocorrectUndo = nil
        bump()
        updateSuggestions()
        return insertToken
    }

    func kbUndoInsert(token: Int) {
        guard token == insertToken else { return }
        proxy.deleteBackward()
        shift = shiftSnapshotForUndo
        bump()
        updateSuggestions()
    }

    func kbDeleteBackward() {
        // Se acabou de autocorrigir, apagar volta para o que você digitou.
        if let u = autocorrectUndo,
           (proxy.documentContextBeforeInput ?? "").hasSuffix(u.corrected + " ") {
            for _ in 0..<(u.corrected.count + 1) { proxy.deleteBackward() }
            proxy.insertText(u.original)
            autocorrectUndo = nil
            bump()
            updateSuggestions()
            return
        }
        autocorrectUndo = nil
        proxy.deleteBackward()
        bump()
        updateSuggestions()
    }

    func kbDeleteWord() {
        autocorrectUndo = nil
        let before = proxy.documentContextBeforeInput ?? ""
        guard !before.isEmpty else {
            proxy.deleteBackward()
            bump()
            return
        }
        var count = 0
        if before.last?.isNewline == true {
            count = 1
        } else {
            var idx = before.endIndex
            while idx > before.startIndex {
                let p = before.index(before: idx)
                if before[p].isWhitespace && !before[p].isNewline { count += 1; idx = p } else { break }
            }
            while idx > before.startIndex {
                let p = before.index(before: idx)
                if before[p].isWhitespace { break }
                count += 1
                idx = p
            }
        }
        count = max(1, min(count, 80))
        for _ in 0..<count { proxy.deleteBackward() }
        bump()
        updateSuggestions()
    }

    private func tryAutocorrect() {
        guard settings.autocorrect, proxy.isSecureTextEntry != true else { return }
        let before = proxy.documentContextBeforeInput ?? ""
        let word = SuggestionEngine.currentWord(in: before)
        guard !word.isEmpty else { return }
        let beforeWord = before.dropLast(word.count)
        guard let fix = engine.correction(for: word, previousChar: beforeWord.last, lang: lang) else { return }
        for _ in 0..<word.count { proxy.deleteBackward() }
        proxy.insertText(fix)
        autocorrectUndo = (original: word, corrected: fix)
    }

    func kbSpace() {
        tryAutocorrect()
        let keepUndo = autocorrectUndo
        proxy.insertText(" ")
        autocorrectUndo = keepUndo
        bump()
        updateSuggestions()
    }

    func kbEnter() {
        tryAutocorrect()
        autocorrectUndo = nil
        proxy.insertText("\n")
        bump()
        updateSuggestions()
    }

    // MARK: Shift (toque = maiúscula 1x, toque duplo = caps lock)

    func kbShiftTapped() {
        let now = Date()
        let quick = now.timeIntervalSince(lastShiftTap) < 0.4
        lastShiftTap = now
        switch shift {
        case .off: shift = .once
        case .once: shift = quick ? .locked : .off
        case .locked: shift = .off
        }
    }

    // MARK: Páginas, emoji, ajustes

    func kbPage(_ page: Page) {
        keyboard.page = page
    }

    func kbMoveCursor(_ delta: Int) {
        proxy.adjustTextPosition(byCharacterOffset: delta)
    }

    func kbHaptic() {
        guard settings.haptics else { return }
        impact.impactOccurred()
        impact.prepare()
    }

    func kbLanguageMenuItems() -> [String] {
        var items = [lang.shortName] + Lang.allCases.filter { $0 != lang }.map { $0.shortName }
        if needsInputModeSwitchKey { items.append("🌐") }
        return items
    }

    func kbLanguageMenuChosen(_ item: String) {
        if item == "🌐" {
            advanceToNextInputMode()
            return
        }
        guard let l = Lang.allCases.first(where: { $0.shortName == item }) else { return }
        lang = l
        settings.language = l
        keyboard.lang = l
        autocorrectUndo = nil
        updateSuggestions()
    }

    func kbEmoji() {
        guard emojiPanel == nil else { return }
        let panel = EmojiPanel(palette: currentPalette())
        panel.frame = view.bounds
        panel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        panel.onPick = { [weak self] e in
            guard let self = self else { return }
            self.proxy.insertText(e)
            self.autocorrectUndo = nil
            self.bump()
        }
        panel.onDelete = { [weak self] in self?.kbDeleteBackward() }
        panel.onHaptic = { [weak self] in self?.kbHaptic() }
        panel.onBack = { [weak self] in
            self?.emojiPanel?.removeFromSuperview()
            self?.emojiPanel = nil
        }
        view.addSubview(panel)
        emojiPanel = panel
    }

    func kbOpenSettings() {
        guard settingsPanel == nil else { return }
        let panel = SettingsPanel(palette: currentPalette(), showSwitchKeyboard: needsInputModeSwitchKey)
        panel.frame = view.bounds
        panel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        panel.onClose = { [weak self] in
            self?.settingsPanel?.removeFromSuperview()
            self?.settingsPanel = nil
        }
        panel.onChange = { [weak self] in self?.applyTheme() }
        panel.onSwitchKeyboard = { [weak self] in self?.advanceToNextInputMode() }
        view.addSubview(panel)
        settingsPanel = panel
    }

    // MARK: Sugestões

    private func updateSuggestions() {
        guard settings.suggestions, proxy.isSecureTextEntry != true else {
            bar.set([])
            return
        }
        let before = proxy.documentContextBeforeInput ?? ""
        let word = SuggestionEngine.currentWord(in: before)
        guard !word.isEmpty else {
            bar.set([])
            return
        }
        var items = [word]
        items += engine.suggestions(for: word, lang: lang)
        bar.set(Array(items.prefix(3)))
    }

    private func pickSuggestion(_ text: String) {
        let before = proxy.documentContextBeforeInput ?? ""
        let word = SuggestionEngine.currentWord(in: before)
        for _ in 0..<word.count { proxy.deleteBackward() }
        proxy.insertText(text + " ")
        autocorrectUndo = nil
        bump()
        updateSuggestions()
    }
}
