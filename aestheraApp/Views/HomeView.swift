//
//  HomeView.swift
//  aestheraApp
//

import SwiftUI

struct HomeView: View {

    @State private var showGallerySheet = false

    // The "+" sheet uses its own NavigationStack and so needs its own
    // AppRouter — sheets don't share navigation state with the parent tab.
    @State private var sheetRouter = AppRouter()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // --- Brand block ---
            VStack(spacing: 8) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 64))
                    .foregroundStyle(.primary)

                Text("aesthera")
                    .font(.largeTitle.weight(.semibold))
                    .tracking(3)

                Text("Facial proportion analysis & drawing guide")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // --- Primary actions ---
            // NavigationLink(value:) pushes a Route onto the home stack's
            // path; destinations are registered once in MainTabView.
            VStack(spacing: 12) {

                NavigationLink(value: AppRouter.Route.curatedReferences) {
                    Text("Curated References")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)

                NavigationLink(value: AppRouter.Route.tutorial) {
                    Text("Tutorial")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // PRD: "+" button spawns the gallery sheet.
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showGallerySheet = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        // The sheet has its OWN NavigationStack and OWN router instance.
        .sheet(isPresented: $showGallerySheet) {
            NavigationStack(path: $sheetRouter.path) {
                SheetGalleryView()
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        sheetDestination(for: route)
                            .environment(sheetRouter)
                    }
            }
            .environment(sheetRouter)
        }
        .onChange(of: showGallerySheet) { _, isShowing in
            // Clean slate every time the sheet is reopened.
            if !isShowing { sheetRouter.popToRoot() }
        }
    }

    /// Routes resolvable inside the "+" sheet stack.
    /// Subset of the home tab's routes — only ones the sheet flow uses.
    @ViewBuilder
    private func sheetDestination(for route: AppRouter.Route) -> some View {
        switch route {
        case .camera:   CameraView()
        case .loading:  LoadingViewHost()
        case .result:   ResultViewHost()
        case .fail:     FailViewHost()
        case .canvas:   DrawingCanvasViewHost()
        default:        Text("Unsupported route in sheet")
                            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(AppRouter())
    }
}
