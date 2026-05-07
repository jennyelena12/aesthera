//
//  OnboardingView.swift
//  aestheraApp
//
//  Onboarding / tutorial flow.
//
//  Layout pattern (top → bottom):
//   1. Background image — fills the whole screen, crossfades when the user
//      swipes between pages. Does NOT slide horizontally.
//   2. TabView (.page style) — holds ONLY the per-page content (image,
//      title, subtitle). This is the part that swipes.
//   3. Fixed bottom bar — page indicator dots + CTA button. These NEVER
//      move regardless of which page is showing.
//
//  Why this structure: putting the button inside the TabView would make
//  it swipe with the content, which is what you don't want. Putting it
//  outside the TabView (in a parent VStack) keeps it pinned.
//

import SwiftUI


// MARK: - Data model

struct OnboardingPage {
    let image: String         // background asset name
    let tutimage: String      // centered illustration
    let title: String
    let subtitle: String
    let buttonText: String    // text shown on the bottom CTA when this page is active
}

let pages = [
    OnboardingPage(
        image: "bg1",
        tutimage: "tut1",
        title: "Pick Your Potion!",
        subtitle: "Upload a portrait or snap a photo to begin your magic.",
        buttonText: "Continue"
    ),
    OnboardingPage(
        image: "bg2",
        tutimage: "tut2",
        title: "Brew The Proportion!",
        subtitle: "We'll generate guiding lines to help you get the proportions just right.",
        buttonText: "Continue"
    ),
    OnboardingPage(
        image: "bg3",
        tutimage: "tut3",
        title: "Craft Your Masterpiece!",
        subtitle: "Draw on our canvas or download your guide to create anywhere you like!",
        buttonText: "I'm ready"
    )
]


// MARK: - Per-page content (the swipeable bit)

struct OnboardingPageContent: View {

    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(page.tutimage)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .clipShape(Capsule())

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - Root

struct OnboardingView: View {

    @Environment(\.dismiss) private var dismiss

    /// Tracks which page the TabView is showing. Drives both the page
    /// indicator dots and the bottom button's text/action.
    @State private var currentPage: Int = 0


    var body: some View {
        ZStack {

            // ── Background layer ────────────────────────────────────────
            // All backgrounds stacked; we crossfade by toggling opacity.
            // This is more reliable than .transition and keeps the
            // background from sliding sideways when the user swipes.
            ZStack {
                ForEach(pages.indices, id: \.self) { index in
                    Image(pages[index].image)
                        .resizable()
                        .scaledToFill()
                        .opacity(currentPage == index ? 1 : 0)
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: currentPage)

            // Dim overlay so white text reads clearly on any background
            Color.black.opacity(0.30)
                .ignoresSafeArea()


            // ── Foreground layout column ────────────────────────────────
            VStack(spacing: 0) {

                // ── Skip link (top-right, always visible) ───────────────
                // HIG: action items in nav-bar zone use ~17pt body weight,
                // sit ~8–16pt inside the safe area, with a tap target ≥44pt.
                // Internal padding doubles as the tap target — don't shrink it.
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, Spacing.m)
                            .padding(.vertical, Spacing.s)
                            .contentShape(Rectangle())   // full padded area is tappable
                    }
                }
                .padding(.horizontal, Spacing.s)
                .padding(.top, Spacing.l)   // breathing room below the safe-area inset

                // Swipeable per-page content
                // NOTE: page-style TabView is fussy about programmatic
                // selection. Two things matter:
                //   1. Use explicit 0..<count, not pages.indices
                //   2. Apply animation via .animation(_:value:) on the TabView,
                //      NOT via withAnimation { currentPage += 1 } from outside.
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageContent(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))   // we draw our own dots
                .animation(.easeInOut(duration: 0.35), value: currentPage)

                // ── Fixed bottom bar (does NOT swipe) ───────────────────
                // HIG-aligned: dots are always at the same vertical position;
                // the CTA slot is reserved (fixed height) so the layout never
                // jumps — the button just fades in on the last page.
                VStack(spacing: Spacing.xl) {

                    // Page indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index
                                      ? Color.white
                                      : Color.white.opacity(0.35))
                                .frame(width: currentPage == index ? 22 : 8, height: 8)
                                .animation(.spring(response: 0.3,
                                                   dampingFraction: 0.85),
                                           value: currentPage)
                        }
                    }

                    // CTA slot — button only on the last page.
                    // Reserved height keeps the dots' position stable;
                    // .opacity + .disabled hides it on earlier pages without
                    // shifting the layout.
                    Button {
                        dismiss()
                    } label: {
                        Text("I'm ready")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule().fill(Color.brandNavy)
                            )
                    }
                    .padding(.horizontal, Spacing.xl)
                    .opacity(currentPage == pages.count - 1 ? 1 : 0)
                    .scaleEffect(currentPage == pages.count - 1 ? 1 : 0.96)
                    .disabled(currentPage != pages.count - 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85),
                               value: currentPage)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    OnboardingView()
}
