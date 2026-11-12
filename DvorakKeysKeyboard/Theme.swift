import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

struct Palette {
    let isDark: Bool
    let gradient: [UIColor]
    let keyFill: UIColor
    let specialFill: UIColor
    let pressFill: UIColor
    let text: UIColor
    let subtext: UIColor
    let popupBg: UIColor
    let accent: UIColor
    let glassTint: UIColor
}

enum Theme {
    static let presetNames = ["Grafite", "Oceano", "Aurora", "Pôr do sol", "Floresta"]

    // Cada preset: degradê escuro e degradê claro (cor de cima -> cor de baixo).
    private static let presets: [(dark: [UInt32], light: [UInt32])] = [
        (dark: [0x1C1C1E, 0x2E2E33], light: [0xEAEBEF, 0xD2D4DC]),
        (dark: [0x0B1F3A, 0x14506B], light: [0xD0E8FF, 0xA8D5F4]),
        (dark: [0x1A0B3A, 0x0E5A52], light: [0xE3D8FF, 0xC5F2E7]),
        (dark: [0x3A0B2A, 0x7A2B1B], light: [0xFFDAC8, 0xFFB4C8]),
        (dark: [0x08221A, 0x1F4D2B], light: [0xD7F2D1, 0xB6E0AF])
    ]

    static func palette(isDark: Bool, preset: Int) -> Palette {
        let idx = max(0, min(preset, presets.count - 1))
        let colors = (isDark ? presets[idx].dark : presets[idx].light).map { UIColor(hex: $0) }

        if isDark {
            return Palette(
                isDark: true,
                gradient: colors,
                keyFill: UIColor(white: 1, alpha: 0.20),
                specialFill: UIColor(white: 1, alpha: 0.11),
                pressFill: UIColor(white: 1, alpha: 0.38),
                text: .white,
                subtext: UIColor(white: 1, alpha: 0.55),
                popupBg: UIColor(white: 0.22, alpha: 0.98),
                accent: UIColor(hex: 0x0A84FF),
                glassTint: UIColor(white: 1, alpha: 0.10)
            )
        } else {
            return Palette(
                isDark: false,
                gradient: colors,
                keyFill: UIColor(white: 1, alpha: 0.70),
                specialFill: UIColor(white: 1, alpha: 0.40),
                pressFill: UIColor(white: 0, alpha: 0.18),
                text: UIColor(white: 0, alpha: 0.88),
                subtext: UIColor(white: 0, alpha: 0.45),
                popupBg: UIColor(white: 0.97, alpha: 0.99),
                accent: UIColor(hex: 0x007AFF),
                glassTint: UIColor(white: 0, alpha: 0.08)
            )
        }
    }
}
