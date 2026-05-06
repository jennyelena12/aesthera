//
//  Theme.swift
//  aestheraApp
//
//  Centralized design tokens pulled from the Figma file.
//  IMPORTANT: open Figma → Dev Mode → click any element → copy the exact
//  hex, font, padding, and radius values into the constants below. Every
//  screen reads from here so updating once propagates everywhere.
//

import SwiftUI


// MARK: - Colors

extension Color {

    // ---- Surfaces ----

    /// App background. The warm off-white behind everything.
    static let appBackground       = Color(hex: 0xF5F4ED)

    /// Plain white card surface (used for reference tiles).
    static let cardSurface         = Color.white

    /// Subtle border / hairline color around cards.
    static let cardBorder          = Color(hex: 0xE5E3DA)


    // ---- Brand ----

    /// Dark navy used for the "Open Camera" CTA, the active chip,
    /// and the floating tab bar.
    static let brandNavy           = Color(hex: 0x252741)

    /// Teal used for the "Upload from Photos" CTA.
    static let brandTeal           = Color(hex: 0x5BD3C4)


    // ---- Text ----

    static let textPrimary         = Color(hex: 0x111111)
    static let textSecondary       = Color(hex: 0x6B6B6B)
    static let textOnDark          = Color.white


    // ---- Chip backgrounds ----

    /// Inactive chip pill background (Anime / Manga / SemiRealist / Realist).
    static let chipInactiveBg      = Color(hex: 0xECEAE0)

    /// Active chip pill background (matches brandNavy).
    static let chipActiveBg        = Color.brandNavy


    // ---- Category badge colors (pale tints behind a tiny label) ----

    static let badgeAnimeBg        = Color(hex: 0xF6E6CB)
    static let badgeMangaBg        = Color(hex: 0xF7DECB)
    static let badgeSemiRealistBg  = Color(hex: 0xDDE7F1)
    static let badgeRealistBg      = Color(hex: 0xE6DFF1)
}


// MARK: - Spacing & radii
// Using a small struct (not magic numbers in views) keeps spacing consistent.

enum Spacing {
    static let xs:  CGFloat = 4
    static let s:   CGFloat = 8
    static let m:   CGFloat = 12
    static let l:   CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32

    /// Outer horizontal padding for the whole screen.
    static let screenH: CGFloat = 20
}

enum Radius {
    static let card:    CGFloat = 16
    static let image:   CGFloat = 12
    static let chip:    CGFloat = 100   // capsule
    static let badge:   CGFloat = 6
}


// MARK: - Typography
// Using SF Pro for now. If Figma specifies a custom font (e.g. "Quicksand",
// "Plus Jakarta Sans"), drop the .ttf into the project, register it in
// Info.plist (UIAppFonts), and swap the calls below to use that family.

extension Font {

    /// "What are we drawing today?" — main screen heading.
    static let screenTitle    = Font.system(size: 26, weight: .bold,    design: .default)

    /// "Pick your own reference" / "Pick from our examples" section heads.
    static let sectionTitle   = Font.system(size: 18, weight: .semibold, design: .default)

    /// CTA card titles ("Open Camera", "Upload from Photos").
    static let ctaTitle       = Font.system(size: 22, weight: .bold,    design: .default)

    /// Reference card title ("Yuji Itadori", "Annabelle"...).
    static let cardTitle      = Font.system(size: 17, weight: .semibold, design: .default)

    /// Filter chip label.
    static let chip           = Font.system(size: 15, weight: .semibold, design: .default)

    /// Tiny category badge under each card.
    static let badge          = Font.system(size: 11, weight: .semibold, design: .default)

    /// Bottom tab label.
    static let tabLabel       = Font.system(size: 13, weight: .semibold, design: .default)
}


// MARK: - Color hex helper

extension Color {
    /// `Color(hex: 0xF5F4ED)` — convenience init so the tokens above stay readable.
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >>  8) & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
