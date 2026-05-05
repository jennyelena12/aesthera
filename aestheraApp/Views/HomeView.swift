//
//  HomeView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI

struct HomeView: View {

    @State private var showGallerySheet = false
    
    @State private var sheetRouter = AppRouter()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showGallerySheet = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
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
