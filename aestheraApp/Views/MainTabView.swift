//
//  MainTabView.swift
//  aestheraApp
//
//  Custom tab container — does NOT use SwiftUI's `TabView` so we can fully
//  control the floating pill bar shown in the Figma.
//
//  We swap the active screen ourselves and overlay our own bottom bar.
//

import SwiftUI


struct MainTabView: View {

    enum Tab: Hashable {
        case draw
        case myWorks
    }

    @State private var selectedTab: Tab = .draw

    @State private var drawRouter    = AppRouter()
    @State private var historyRouter = AppRouter()


    var body: some View {
        ZStack(alignment: .bottom) {

            // ------- Active screen -------
            Group {
                switch selectedTab {
                case .draw:
                    NavigationStack(path: $drawRouter.path) {
                        HomeView()
                            .navigationDestination(for: AppRouter.Route.self) { route in
                                destinationView(for: route)
                                    .environment(drawRouter)
                            }
                    }
                    .environment(drawRouter)

                case .myWorks:
                    NavigationStack(path: $historyRouter.path) {
                        SavedResultsView()
                            .navigationDestination(for: AppRouter.Route.self) { route in
                                destinationView(for: route)
                                    .environment(historyRouter)
                            }
                    }
                    .environment(historyRouter)
                }
            }

            // ------- Floating bar -------
            FloatingTabBar(selected: $selectedTab)
                .padding(.horizontal, 60)
                .padding(.bottom, 12)
        }
    }


    /// Single source of truth for resolving routes to views.
    /// Heavy payloads (image, faces, message) come from the router
    /// via the host wrappers, so the Route enum stays simple/Hashable.
    @ViewBuilder
    private func destinationView(for route: AppRouter.Route) -> some View {
        switch route {
        case .faceScanner:        FaceScannerView()
        case .curatedReferences:  CuratedReferencesView()
        case .tutorial:           TutorialView()
        case .sheetGallery:       SheetGalleryView()
        case .camera:             CameraView()
        case .loading:            LoadingViewHost()
        case .result:             ResultViewHost()
        case .fail:               FailViewHost()
        case .canvas:             DrawingCanvasViewHost()
        }
    }
}


// MARK: - Floating bar

private struct FloatingTabBar: View {

    @Binding var selected: MainTabView.Tab

    var body: some View {
        HStack(spacing: 0) {

            tabButton(
                tab: .draw,
                label: "Draw",
                systemImage: "pencil"
            )

            tabButton(
                tab: .myWorks,
                label: "My Works",
                systemImage: "book"
            )
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.cardSurface)
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 4)
        )
        .overlay(
            Capsule().stroke(Color.cardBorder, lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private func tabButton(tab: MainTabView.Tab, label: String, systemImage: String) -> some View {
        let isActive = selected == tab

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selected = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(.tabLabel)
            }
            .foregroundStyle(isActive ? Color.textOnDark : Color.textPrimary)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().fill(isActive ? Color.brandNavy : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    MainTabView()
}
