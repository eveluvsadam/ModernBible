import SwiftUI

final class ThemeManager: ObservableObject {
    @AppStorage("appTheme") private var storedTheme: String = AppTheme.system.rawValue
    @AppStorage("fontSize") var fontSize: Double = 17
    @AppStorage("readingBackground") var readingBackground: String = "default"

    @Published var theme: AppTheme = .system {
        didSet { storedTheme = theme.rawValue }
    }

    init() {
        theme = AppTheme(rawValue: storedTheme) ?? .system
    }

    var colorScheme: ColorScheme? {
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var accentColor: Color {
        Color("AccentColor") // define in Assets.xcassets — a warm, calm accent (e.g. deep amber/burgundy)
    }

    /// Bundled reading background presets (subtle textures/gradients — never impair legibility).
    static let backgroundOptions: [String] = ["default", "parchment", "linen", "midnight", "sepia"]

    func readingBackgroundView() -> some View {
        LinearGradient(
            colors: Self.gradientColors(for: readingBackground),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private static func gradientColors(for key: String) -> [Color] {
        switch key {
        case "parchment": return [Color(hex: "#F5ECD9"), Color(hex: "#EFE2C6")]
        case "linen":     return [Color(hex: "#F7F5F2"), Color(hex: "#ECE8E1")]
        case "midnight":  return [Color(hex: "#12141C"), Color(hex: "#1C2030")]
        case "sepia":     return [Color(hex: "#F1E7D0"), Color(hex: "#E4D3AE")]
        default:          return [Color(.systemBackground), Color(.systemBackground)]
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
