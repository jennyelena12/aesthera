//
//  MainTabView.swift
//  aestheraApp
//
//  Custom tab container — does NOT use SwiftUI's `TabView` so we can fully
//  control the floating pill bar shown in the Figma.
//
//  Floating bar follows Apple HIG Liquid Glass design language (iOS 26 / visionOS).
//  – Icon stacked above label (VStack), matching HIG tab layout
//  – Outer container: .ultraThinMaterial + specular gradient + gradient rim stroke
//  – Active pill: brandNavy base + glass sheen overlay + bright top rim
//  – Multi-layer shadow for perceived depth
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
                        SavedResultsView(onBackToDraw: {
                            withAnimation {
                                selectedTab = .draw
                            }
                        })
                        .navigationDestination(for: AppRouter.Route.self) { route in
                            destinationView(for: route)
                                .environment(historyRouter)
                        }
                    }
                    .environment(historyRouter)
                }
            }
            
            // ------- Floating liquid glass bar -------
            
            if shouldShowTabBar {
                FloatingTabBar(selected: $selectedTab)
                    .padding(.horizontal, 60)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: shouldShowTabBar)
    }

    private var shouldShowTabBar: Bool {
        switch selectedTab {
        case .draw:
            return drawRouter.path.isEmpty
        case .myWorks:
            return historyRouter.path.isEmpty
        }
    }
    
    
    /// Single source of truth for resolving routes to views.
    @ViewBuilder
    private func destinationView(for route: AppRouter.Route) -> some View {
        switch route {
//        case .faceScanner:        FaceScannerView()
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


// MARK: - Floating liquid glass tab bar

private struct FloatingTabBar: View {
    
    @Binding var selected: MainTabView.Tab
    
    var body: some View {
        HStack(spacing: 0) {
            
            tabButton(tab: .draw, label: "Draw") {
                // Pen icon
                Image(systemName: selected == .draw ? "pencil" : "pencil")
                    .font(.system(size: 22, weight: selected == .draw ? .bold : .medium))
            }
            
            tabButton(tab: .myWorks, label: "My Works") {
                // Book with bookmark: closed book + small bookmark badge
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 22, weight: selected == .myWorks ? .bold : .medium))
                    
                }
            }
        }
        .padding(6)
        // ── Liquid glass container ─────────────────────────────────────────────
        .background {
            ZStack {
                // Layer 1 — frosted blur material
                Capsule()
                    .fill(.ultraThinMaterial)
                
                // Layer 2 — specular gradient: bright top, fades out
                Capsule()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.42), location: 0.00),
                                .init(color: .white.opacity(0.18), location: 0.30),
                                .init(color: .white.opacity(0.05), location: 0.60),
                                .init(color: .clear,               location: 1.00),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        // Layer 3 — gradient rim: white top edge (glass catch-light), dark fade
        .overlay {
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.80), location: 0.00),
                            .init(color: .white.opacity(0.35), location: 0.45),
                            .init(color: .white.opacity(0.08), location: 1.00),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.0
                )
        }
        // Multi-layer shadow for glass depth
        .shadow(color: .black.opacity(0.20), radius: 28, x: 0, y: 12)
        .shadow(color: .black.opacity(0.08), radius:  6, x: 0, y:  3)
    }
    
    @ViewBuilder
    private func tabButton<Icon: View>(
        tab: MainTabView.Tab,
        label: String,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        let isActive = selected == tab
        
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                selected = tab
            }
        } label: {
            // HIG Liquid Glass tab layout: icon stacked above label
            VStack(spacing: 5) {
                icon()
                    .symbolRenderingMode(.hierarchical)
                    .frame(height: 24)
                
                Text(label)
                    .font(.tabLabel)
            }
            .foregroundStyle(
                isActive
                ? Color.textOnDark
                : Color.textPrimary.opacity(0.70)
            )
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            // ── Active glass pill ──────────────────────────────────────────────
            .background {
                if isActive {
                    ZStack {
                        // Base: brand navy fill
                        Capsule()
                            .fill(Color.brandNavy)
                        
                        // Glass sheen over navy — light catches the top
                        Capsule()
                            .fill(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.22), location: 0.00),
                                        .init(color: .white.opacity(0.08), location: 0.45),
                                        .init(color: .clear,               location: 1.00),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Bright top rim on the pill (glass edge refraction)
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(0.50), location: 0.00),
                                        .init(color: .white.opacity(0.15), location: 0.55),
                                        .init(color: .clear,               location: 1.00),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.75
                            )
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        MainTabView()
    }
}
