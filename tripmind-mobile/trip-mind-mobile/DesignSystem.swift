//
//  DesignSystem.swift
//  trip-mind-mobile
//
//  Design tokens and styling constants
//

import SwiftUI

struct DesignSystem {
    // MARK: - Colors
    
    // Primary color: oklch(0.4714 0.2473 284.71) - Deep Purple/Indigo
    static let primary = Color(red: 0.4714, green: 0.2473, blue: 0.28471)
    
    // For SwiftUI, we'll use a more standard approach with hex
    // Primary: #6B46C1 (Indigo/Purple approximation)
    static let primaryColor = Color(hex: "6B46C1")
    static let primaryForeground = Color.white
    
    // Background & Text
    static let background = Color.white
    static let foreground = Color(hex: "1F1F1F") // Nearly black
    static let card = Color.white
    static let border = Color(hex: "EBEBEB") // Very light gray
    
    // Muted colors
    static let muted = Color(hex: "F7F7F7")
    static let mutedForeground = Color(hex: "8E8E8E")
    
    // Destructive (red)
    static let destructive = Color(hex: "DC2626")
    
    // MARK: - Spacing
    
    static let spacing1: CGFloat = 4
    static let spacing2: CGFloat = 8
    static let spacing3: CGFloat = 12
    static let spacing4: CGFloat = 16
    static let spacing6: CGFloat = 24
    static let spacing8: CGFloat = 32
    
    // MARK: - Border Radius
    
    static let radiusSmall: CGFloat = 6
    static let radiusMedium: CGFloat = 8
    static let radiusLarge: CGFloat = 10
    static let radiusXLarge: CGFloat = 12
    static let radiusFull: CGFloat = 999
    
    // MARK: - Typography
    
    enum FontSize {
        case xs, sm, base, lg, xl, xl2, xl3
        
        var value: CGFloat {
            switch self {
            case .xs: return 12
            case .sm: return 14
            case .base: return 16
            case .lg: return 18
            case .xl: return 20
            case .xl2: return 24
            case .xl3: return 30
            }
        }
    }
    
    // MARK: - Button Heights
    
    static let buttonHeightSmall: CGFloat = 32
    static let buttonHeightDefault: CGFloat = 36
    static let buttonHeightLarge: CGFloat = 40
    static let buttonHeightTouch: CGFloat = 44 // Minimum touch target
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
