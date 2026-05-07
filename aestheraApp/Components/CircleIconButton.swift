//
//  CircleIconButton.swift
//  aestheraApp
//
//  Reusable circular icon button used in nav-bar zones across the app
//  (back, save, "+", help, etc.). Two style variants:
//
//   • .secondary  — white surface, hairline border, subtle shadow.
//                   Used for back, save, info — anything that's "extra".
//   • .primary    — brandNavy fill, white icon. Used for the main action
//                   in a screen's nav zone (e.g. "+" to add a new item).
//
//  Usage:
//
//      CircleIconButton(systemName: "chevron.left") { router.popOne() }
//
//      CircleIconButton(systemName: "plus", style: .primary) { addItem() }
//
//  When you need to use the same look as a Menu label (where the tap is
//  already handled by the Menu), use CircleIconChrome directly:
//
//      Menu { … } label: {
//          CircleIconChrome(systemName: "plus", style: .primary)
//      }
//

import SwiftUI


// MARK: - Style

enum CircleIconStyle {
    case secondary
    case primary
}


// MARK: - Visual chrome (no button wrapping)
// Use this when the tap interaction is owned by something else (e.g. Menu).

struct CircleIconChrome: View {

    let systemName: String
    var style: CircleIconStyle = .secondary
    var size: CGFloat = 40
    var iconSize: CGFloat = 16


    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(foreground)
            .frame(width: size, height: size)
            .background(background, in: Circle())
            .overlay(borderOverlay)
            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }


    // MARK: - Style mapping

    private var foreground: Color {
        switch style {
        case .secondary: return Color.textPrimary
        case .primary:   return Color.textOnDark
        }
    }

    private var background: Color {
        switch style {
        case .secondary: return Color.cardSurface
        case .primary:   return Color.brandNavy
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .secondary:
            Circle().stroke(Color.cardBorder, lineWidth: 0.5)
        case .primary:
            EmptyView()
        }
    }

    private var shadowColor: Color {
        switch style {
        case .secondary: return .black.opacity(0.05)
        case .primary:   return .black.opacity(0.10)
        }
    }
}


// MARK: - Button wrapper

struct CircleIconButton: View {

    let systemName: String
    var style: CircleIconStyle = .secondary
    var size: CGFloat = 40
    var iconSize: CGFloat = 16
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CircleIconChrome(
                systemName: systemName,
                style: style,
                size: size,
                iconSize: iconSize
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview

#Preview("Both styles") {
    HStack(spacing: 16) {
        CircleIconButton(systemName: "chevron.left") {}
        CircleIconButton(systemName: "bookmark") {}
        CircleIconButton(systemName: "questionmark") {}
        CircleIconButton(systemName: "plus", style: .primary) {}
    }
    .padding()
    .background(Color.appBackground)
}
