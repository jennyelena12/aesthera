//
//  SheetGalleryView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI
import PhotosUI


struct SheetGalleryView: View {

    @Environment(AppRouter.self) private var router

    @State private var selectedItem: PhotosPickerItem? = nil



    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Pick a photo to analyze")
                .font(.headline)
                .foregroundStyle(.secondary)

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
                        router.startScan(with: uiImage)
                        selectedItem = nil
                    }
                }
            }


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
