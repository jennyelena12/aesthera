//
//  MainTabView.swift
//  aestheraApp
//

import SwiftUI

// Each tab gets its own NavigationStack and its own AppRouter, so
// navigation state is independent across tabs. The "+" sheet (presented
// from HomeView) gets a third router — see HomeView for that.
//
// Destination wrappers (LoadingViewHost, ResultViewHost, etc.) live in
// RouteHosts.swift so HomeView's sheet stack can reuse them.

struct MainTabView: View {

    @State private var homeRouter    = AppRouter()
    @State private var historyRouter = AppRouter()

    var body: some View {
        TabView {

            // --- Tab 1: Home ---
            NavigationStack(path: $homeRouter.path) {
                HomeView()
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        destinationView(for: route)
                            .environment(homeRouter)
                    }
            }
            .environment(homeRouter)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            // --- Tab 2: History ---
            NavigationStack(path: $historyRouter.path) {
                SavedResultsView()
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        destinationView(for: route)
                            .environment(historyRouter)
                    }
            }
            .environment(historyRouter)
            .tabItem {
                Label("My Works", systemImage: "bookmark.fill")
            }
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

#Preview {
    MainTabView()
}
