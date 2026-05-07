//
//  PopupCard.swift
//  aestheraApp
//
//  Reusable centered popup card with a dimmed full-screen backdrop.
//
//  Usage:
//
//      PopupCard {
//          VStack(spacing: 16) {
//              ProgressView()
//              Text("Loading…")
//          }
//      }
//
//  You can override size and dim opacity per-call:
//
//      PopupCard(size: CGSize(width: 240, height: 180), dimOpacity: 0.55) { … }
//
//  Best practice:
//   • Card size is hardcoded in pt because popups should look the same on
//     every device — they're not tied to the layout flow.
//   • Use this for transient, non-cancellable states (loading) OR add your
//     own dismiss button inside the content closure.
//

import SwiftUI


struct PopupCard<Content: View>: View {

    // MARK: - Inputs

    let content: () -> Content

    /// Size of the white card in the middle of the screen.
    var size: CGSize = .init(width: 200, height: 200)

    /// 0.0 = transparent, 1.0 = solid black backdrop.
    var dimOpacity: Double = 0.45

    /// Corner radius of the popup card.
    var cornerRadius: CGFloat = 20


    // MARK: - Init

    init(
        size: CGSize = .init(width: 200, height: 200),
        dimOpacity: Double = 0.45,
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.size         = size
        self.dimOpacity   = dimOpacity
        self.cornerRadius = cornerRadius
        self.content      = content
    }


    // MARK: - Body

    var body: some View {
        ZStack {
            // ── Dimmed full-screen backdrop ─────────────────────────────
            Color.black.opacity(dimOpacity)
                .ignoresSafeArea()

            // ── Centered card ──────────────────────────────────────────
            content()
                .padding(Spacing.l)
                .frame(width: size.width, height: size.height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.cardSurface)
                )
                .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
        }
    }
}


// MARK: - Previews

#Preview("Loading popup") {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        Text("Underlying screen content").foregroundStyle(.secondary)

        PopupCard {
            VStack(spacing: 16) {
                ProgressView().scaleEffect(1.4).tint(Color.brandNavy)
                Text("Detecting face\nproportions…")
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)
            }
        }
    }
}


#Preview("Wider success popup") {
    ZStack {
        Color.appBackground.ignoresSafeArea()

        PopupCard(size: CGSize(width: 260, height: 180)) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.brandTeal)
                Text("Saved to My Works")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
            }
        }
    }
}
