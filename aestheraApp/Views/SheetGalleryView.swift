//
//  SheetGalleryView.swift
//  aestheraApp
//

import SwiftUI
import PhotosUI

// SheetGalleryView is the root of the "+" sheet's NavigationStack.
// It hands off to AppRouter on photo selection, just like CuratedReferencesView does.

struct SheetGalleryView: View {

    @Environment(AppRouter.self) private var router

    @State private var selectedItem: PhotosPickerItem? = nil

    // TODO: Replace with real 3x3 clickable photo grid from Figma
    // TODO: Add notification banner — "only face photos with visible details"
    //       auto-closes after 10s

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Pick a photo to analyze")
                .font(.headline)
                .foregroundStyle(.secondary)

            // Temporary: plain PhotosPicker until the 3x3 grid is designed.
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Open Photo Library")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        // Hand off to the router. The sheet's stack handles
                        // the rest (loading → result/fail → canvas).
                        router.startScan(with: uiImage)
                        selectedItem = nil // reset so the same image can be picked again
                    }
                }
            }

            // Camera entry point — pushes the camera screen as a route.
            NavigationLink(value: AppRouter.Route.camera) {
                Label("Use Camera", systemImage: "camera.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 24)

            Spacer()
        }
        .navigationTitle("Gallery")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SheetGalleryView()
            .environment(AppRouter())
    }
}
