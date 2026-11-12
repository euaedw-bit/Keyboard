import UIKit

enum Page {
    case letters, numbers, symbols
}

enum Lang: String, CaseIterable {
    case en, es, pt, ru

    var displayName: String {
        switch self {
        case .en: return "English (US)"
        case .es: return "Español"
        case .pt: return "Português (BR)"
        case .ru: return "Русский"
        }
    }

    var shortName: String { rawValue.uppercased() }

    var checkerLanguage: String {
        switch self {
        case .en: return "en_US"
        case .es: return "es_ES"
        case .pt: return "pt_BR"
        case .ru: return "ru_RU"
        }
    }

    var isCyrillic: Bool { self == .ru }
}

enum KeyAction {
    case text
    case shift
    case delete
    case space
    case enter
    case page(Page)
    case emoji
    case spacer
}

struct KeyDef {
    var action: KeyAction
    var label: String        // texto normal (e o que é inserido)
    var upper: String        // texto com shift
    var alts: [String] = []  // long-press, da tecla para fora (mesma ordem do seu teclado)
    var width: CGFloat = 1

    var isSpacer: Bool {
        if case .spacer = action { return true }
        return false
    }

    var isSpecial: Bool {
        switch action {
        case .text, .space, .spacer: return false
        default: return true
        }
    }
}

enum Layouts {

    // MARK: - Long-press (ordem a partir da tecla, copiada dos seus prints)

    static let latinAlts: [String: [String]] = [
        "a": ["@", "°", "á", "ā", "ä", "ã", "â", "å", "à", "ă", "ą", "ǎ", "ạ", "æ"],
        "o": ["#", "ó", "ö", "ō", "ø", "ô", "ò", "õ", "ő"],
        "e": ["é", "¤", "£", "₵", "$", "¥", "€", "₱", "è", "ę", "ë", "ê", "ě", "ē", "ė", "ȩ"],
        "u": ["_", "ü", "ū", "ú", "ù", "ư"],
        "i": ["&", "í", "ī", "ı", "î", "ì", "ï"],
        "d": ["đ", "ð"],
        "h": ["+", "ḩ", "ḥ"],
        "t": ["(", "ț", "ţ", "þ"],
        "n": ["ñ", ")", "ń", "ň"],
        "s": ["/", "š", "ş", "ś", "ș", "ß"],
        "z": ["ž", "ż", "ź"],
        "m": [";"],
        "b": [":"],
        "w": ["!"],
        "v": ["?"],
        "k": ["\""],
        "j": ["*"],
        "l": ["0", "ł"],
        "r": ["9", "ř"],
        "c": ["8", "ç", "č", "ć"],
        "g": ["7", "ğ"],
        "f": ["6"],
        "y": ["5", "ý"],
        "p": ["4"]
    ]

    // Suposição minha (você ainda não mandou os long-press do russo): ё e э em "е", ъ em "ь".
    static let russianAlts: [String: [String]] = [
        "е": ["ё", "э"],
        "ь": ["ъ"]
    ]

    // MARK: - Construtores

    private static func ch(_ s: String, up: String? = nil, alts: [String]? = nil, w: CGFloat = 1,
                           cyrillic: Bool = false) -> KeyDef {
        let table = cyrillic ? russianAlts : latinAlts
        return KeyDef(action: .text, label: s, upper: up ?? s.uppercased(),
                      alts: alts ?? (table[s] ?? []), width: w)
    }

    private static func spacer(_ w: CGFloat) -> KeyDef {
        KeyDef(action: .spacer, label: "", upper: "", alts: [], width: w)
    }

    private static func shiftKey() -> KeyDef {
        KeyDef(action: .shift, label: "shift", upper: "shift", alts: [], width: 1)
    }

    private static func deleteKey(_ w: CGFloat = 1) -> KeyDef {
        KeyDef(action: .delete, label: "delete", upper: "delete", alts: [], width: w)
    }

    private static func pageKey(_ p: Page, _ title: String, _ w: CGFloat) -> KeyDef {
        KeyDef(action: .page(p), label: title, upper: title, alts: [], width: w)
    }

    private static func emojiKey(_ w: CGFloat = 1.2) -> KeyDef {
        KeyDef(action: .emoji, label: "emoji", upper: "emoji", alts: [], width: w)
    }

    private static func spaceKey(_ w: CGFloat) -> KeyDef {
        KeyDef(action: .space, label: " ", upper: " ", alts: [], width: w)
    }

    private static func enterKey(_ w: CGFloat) -> KeyDef {
        KeyDef(action: .enter, label: "enter", upper: "enter", alts: [], width: w)
    }

    private static func plain(_ s: String, w: CGFloat = 1, alts: [String] = []) -> KeyDef {
        KeyDef(action: .text, label: s, upper: s, alts: alts, width: w)
    }

    private static func digits(side: CGFloat) -> [KeyDef] {
        var row: [KeyDef] = []
        if side > 0 { row.append(spacer(side)) }
        for d in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] { row.append(plain(d)) }
        if side > 0 { row.append(spacer(side)) }
        return row
    }

    // MARK: - Páginas

    static func rows(page: Page, lang: Lang) -> [[KeyDef]] {
        switch page {
        case .letters: return lang.isCyrillic ? russian() : latin()
        case .numbers: return numbers()
        case .symbols: return symbols()
        }
    }

    private static func latin() -> [[KeyDef]] {
        let cols: CGFloat = 11
        let row1: [KeyDef] = [
            ch("?", up: "\"", alts: ["'"]),
            ch(",", up: "<", alts: ["2"]),
            ch(".", up: ">", alts: [",", "?", "!", ":", ";"]),
            ch("p"), ch("y"), ch("f"), ch("g"), ch("c"), ch("r"), ch("l"),
            ch("/", up: "?", alts: ["="])
        ]
        let row2: [KeyDef] = [
            ch("a"), ch("o"), ch("e"), ch("u"), ch("i"), ch("d"), ch("h"), ch("t"), ch("n"), ch("s"),
            ch("-", up: "_", alts: ["–", "—", "•"])
        ]
        var row3: [KeyDef] = [shiftKey()]
        for c in ["q", "j", "k", "x", "b", "m", "w", "v", "z"] { row3.append(ch(c)) }
        row3.append(deleteKey())

        let fixed: CGFloat = 1.5 + 1.2 + 1.2 + 2.3
        let bottom: [KeyDef] = [
            pageKey(.numbers, "123", 1.5),
            emojiKey(1.2),
            spaceKey(cols - fixed),
            ch(".", up: ".", alts: [",", "?", "!", ":", ";"], w: 1.2),
            enterKey(2.3)
        ]
        return [digits(side: 0.5), row1, row2, row3, bottom]
    }

    private static func russian() -> [[KeyDef]] {
        let cols: CGFloat = 12
        func r(_ s: String) -> KeyDef { ch(s, cyrillic: true) }

        let row1 = ["я", "в", "е", "р", "т", "ы", "у", "и", "о", "п", "ш", "щ"].map(r)
        var row2: [KeyDef] = [spacer(1)]
        row2 += ["а", "с", "д", "ф", "г", "ч", "й", "к", "л", "ь"].map(r)
        row2.append(spacer(1))

        var row3: [KeyDef] = [
            KeyDef(action: .shift, label: "shift", upper: "shift", alts: [], width: 1.5),
            spacer(0.5)
        ]
        row3 += ["з", "х", "ц", "ж", "б", "н", "м", "ю"].map(r)
        row3.append(spacer(0.5))
        row3.append(deleteKey(1.5))

        let fixed: CGFloat = 1.5 + 1.2 + 1.2 + 2.3
        let bottom: [KeyDef] = [
            pageKey(.numbers, "123", 1.5),
            emojiKey(1.2),
            spaceKey(cols - fixed),
            ch(".", up: ".", alts: [",", "?", "!", ":", ";"], w: 1.2),
            enterKey(2.3)
        ]
        return [digits(side: 1), row1, row2, row3, bottom]
    }

    private static func bottomSymbolRow() -> [KeyDef] {
        [pageKey(.letters, "ABC", 1.5), emojiKey(1.2), spaceKey(5.0), enterKey(2.3)]
    }

    private static func numbers() -> [[KeyDef]] {
        let row0 = digits(side: 0)
        let row1 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""].map { plain($0) }
        var row2: [KeyDef] = [pageKey(.symbols, "#+=", 1.5)]
        row2 += [".", ",", "?", "!", "'"].map { plain($0, w: 1.3) }
        row2.append(deleteKey(2.0))
        return [row0, row1, row2, bottomSymbolRow()]
    }

    private static func symbols() -> [[KeyDef]] {
        let row0 = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="].map { plain($0) }
        let row1 = ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"].map { plain($0) }
        var row2: [KeyDef] = [pageKey(.numbers, "123", 1.5)]
        row2 += [".", ",", "?", "!", "'"].map { plain($0, w: 1.3) }
        row2.append(deleteKey(2.0))
        return [row0, row1, row2, bottomSymbolRow()]
    }

    /// Maiúscula para os extras do long-press (ß vira ẞ; símbolos ficam como estão).
    static func upperAlt(_ s: String) -> String {
        if s == "ß" { return "ẞ" }
        let u = s.uppercased()
        return u.count == s.count ? u : s
    }
}
