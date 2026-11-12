import UIKit

enum ThemeMode: Int {
    case auto = 0, dark, light
}

enum KeyStyle: Int {
    case glass = 0   // Liquid Glass (iOS 26+; em versões anteriores cai para "fosco")
    case frosted = 1 // translúcido simples, bem mais leve
}

/// Ajustes guardados no próprio teclado (UserDefaults da extensão).
/// Não usa App Group de propósito: funciona em conta gratuita de sideload.
final class Settings {
    static let shared = Settings()
    private let d = UserDefaults.standard

    /// Segundos segurando o "123" para abrir os ajustes.
    let settingsHoldSeconds: TimeInterval = 3.0

    private func bool(_ key: String, _ fallback: Bool) -> Bool {
        d.object(forKey: key) == nil ? fallback : d.bool(forKey: key)
    }

    private func double(_ key: String, _ fallback: Double) -> Double {
        d.object(forKey: key) == nil ? fallback : d.double(forKey: key)
    }

    var keyScale: CGFloat {
        get { CGFloat(double("keyScale", 1.0)) }
        set { d.set(Double(newValue), forKey: "keyScale") }
    }

    var themeMode: ThemeMode {
        get { ThemeMode(rawValue: d.integer(forKey: "themeMode")) ?? .auto }
        set { d.set(newValue.rawValue, forKey: "themeMode") }
    }

    var keyStyle: KeyStyle {
        get { KeyStyle(rawValue: d.integer(forKey: "keyStyle")) ?? .glass }
        set { d.set(newValue.rawValue, forKey: "keyStyle") }
    }

    var gradientIndex: Int {
        get { d.integer(forKey: "gradientIndex") }
        set { d.set(newValue, forKey: "gradientIndex") }
    }

    var haptics: Bool {
        get { bool("haptics", true) }
        set { d.set(newValue, forKey: "haptics") }
    }

    var suggestions: Bool {
        get { bool("suggestions", true) }
        set { d.set(newValue, forKey: "suggestions") }
    }

    var autocorrect: Bool {
        get { bool("autocorrect", true) }
        set { d.set(newValue, forKey: "autocorrect") }
    }

    /// Distância (pt) do arrasto para a esquerda a partir da qual apaga a palavra inteira.
    var wordSwipeDistance: CGFloat {
        get { CGFloat(double("wordSwipeDistance", 120)) }
        set { d.set(Double(newValue), forKey: "wordSwipeDistance") }
    }

    var language: Lang {
        get { Lang(rawValue: d.string(forKey: "language") ?? "en") ?? .en }
        set { d.set(newValue.rawValue, forKey: "language") }
    }

    var recentEmoji: [String] {
        get { d.stringArray(forKey: "recentEmoji") ?? [] }
        set { d.set(Array(newValue.prefix(32)), forKey: "recentEmoji") }
    }
}
