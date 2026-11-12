import UIKit

/// Sugestões e autocorreção usando o corretor do próprio iOS (UITextChecker).
/// Os dicionários (inglês, espanhol, português, russo) já vêm no iPhone.
final class SuggestionEngine {
    private let checker = UITextChecker()

    /// Palavra sendo digitada logo antes do cursor.
    static func currentWord(in context: String) -> String {
        var chars: [Character] = []
        for ch in context.reversed() {
            if ch.isLetter || ch == "'" || ch == "’" {
                chars.append(ch)
            } else {
                break
            }
        }
        var word = String(chars.reversed())
        while let first = word.first, first == "'" || first == "’" {
            word.removeFirst()
        }
        return word
    }

    private func isMisspelled(_ word: String, lang: Lang) -> Bool {
        let range = NSRange(location: 0, length: (word as NSString).length)
        let r = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0,
                                              wrap: false, language: lang.checkerLanguage)
        return r.location != NSNotFound
    }

    func suggestions(for word: String, lang: Lang) -> [String] {
        guard !word.isEmpty else { return [] }
        let range = NSRange(location: 0, length: (word as NSString).length)
        var result: [String] = []

        if isMisspelled(word, lang: lang),
           let guesses = checker.guesses(forWordRange: range, in: word, language: lang.checkerLanguage) {
            result += guesses
        }
        if let comps = checker.completions(forPartialWordRange: range, in: word, language: lang.checkerLanguage) {
            result += comps
        }

        var seen = Set<String>()
        var out: [String] = []
        for s in result {
            let key = s.lowercased()
            if key == word.lowercased() || seen.contains(key) { continue }
            seen.insert(key)
            out.append(matchCase(s, like: word))
            if out.count >= 3 { break }
        }
        return out
    }

    /// Correção automática conservadora: só troca quando a palavra claramente está errada.
    func correction(for word: String, previousChar: Character?, lang: Lang) -> String? {
        guard word.count >= 2 else { return nil }
        if word.rangeOfCharacter(from: .decimalDigits) != nil { return nil }
        // Não mexe em e-mails, hashtags, menções, URLs, siglas (TUDO MAIÚSCULO) e CamelCase.
        if let p = previousChar, "@#/.".contains(p) { return nil }
        if word == word.uppercased() { return nil }
        let rest = word.dropFirst()
        if rest != rest.lowercased() { return nil }

        guard isMisspelled(word, lang: lang) else { return nil }
        let range = NSRange(location: 0, length: (word as NSString).length)
        guard let guess = checker.guesses(forWordRange: range, in: word, language: lang.checkerLanguage)?.first else {
            return nil
        }
        guard guess.lowercased() != word.lowercased() else { return nil }
        guard abs(guess.count - word.count) <= 2 else { return nil }
        guard guess.first?.lowercased() == word.first?.lowercased() else { return nil }
        return matchCase(guess, like: word)
    }

    private func matchCase(_ s: String, like word: String) -> String {
        guard let first = word.first, first.isUppercase else { return s }
        return s.prefix(1).uppercased() + s.dropFirst()
    }
}

// MARK: - Barra de sugestões (3 slots)

final class SuggestionBar: UIView {
    var onPick: ((String) -> Void)?
    private var buttons: [UIButton] = []
    private var dividers: [UIView] = []
    private var palette: Palette = Theme.palette(isDark: true, preset: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        for i in 0..<3 {
            let b = UIButton(type: .system)
            b.titleLabel?.font = .systemFont(ofSize: 17)
            b.titleLabel?.lineBreakMode = .byTruncatingTail
            b.titleLabel?.adjustsFontSizeToFitWidth = true
            b.titleLabel?.minimumScaleFactor = 0.7
            b.tag = i
            b.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b)
            buttons.append(b)
        }
        for _ in 0..<2 {
            let d = UIView()
            d.isUserInteractionEnabled = false
            addSubview(d)
            dividers.append(d)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w = (bounds.width - 8) / 3
        for (i, d) in dividers.enumerated() {
            d.frame = CGRect(x: 4 + w * CGFloat(i + 1) - 0.5, y: bounds.height * 0.25, width: 1, height: bounds.height * 0.5)
        }
    }

    func apply(palette: Palette) {
        self.palette = palette
        for b in buttons { b.setTitleColor(palette.text, for: .normal) }
        for d in dividers { d.backgroundColor = palette.subtext.withAlphaComponent(0.35) }
    }

    func set(_ items: [String]) {
        for (i, b) in buttons.enumerated() {
            let t = i < items.count ? items[i] : ""
            b.setTitle(t, for: .normal)
            b.isEnabled = !t.isEmpty
        }
    }

    @objc private func tapped(_ sender: UIButton) {
        guard let t = sender.title(for: .normal), !t.isEmpty else { return }
        onPick?(t)
    }
}
