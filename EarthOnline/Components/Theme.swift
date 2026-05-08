import SwiftUI

struct Theme {
    // Retro RPG palette
    static let bg           = Color(hex: "1A1A2E")
    static let bgLight      = Color(hex: "16213E")
    static let panel        = Color(hex: "0F3460")
    static let accent       = Color(hex: "E94560")
    static let gold         = Color(hex: "F5C518")
    static let green        = Color(hex: "00FF88")
    static let blue         = Color(hex: "00D4FF")
    static let purple       = Color(hex: "B347EA")
    static let red           = Color(hex: "FF4757")
    static let orange        = Color(hex: "FF6B35")
    static let text          = Color(hex: "EAEAEA")
    static let textDim       = Color(hex: "8888AA")
    static let hpGreen       = Color(hex: "2ECC71")
    static let mpBlue        = Color(hex: "3498DB")
    static let xpAmber       = Color(hex: "F39C12")

    static let pixelFont: Font = .system(.body, design: .monospaced)
    static let titleFont: Font = .system(.title, design: .monospaced)
    static let headlineFont: Font = .system(.headline, design: .monospaced)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
