//
//  MainTabView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI


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
