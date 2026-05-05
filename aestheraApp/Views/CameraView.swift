//
//  CameraView.swift
//  aestheraApp
//

import SwiftUI

struct CameraView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router

    // TODO: Wire up AVFoundation / UIImagePickerController camera
    // TODO: "Take picture" button → router.startScan(with: capturedImage)
    // TODO: "Gallery" button → dismiss back to SheetGalleryView

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Camera")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Camera capture coming soon.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Spacer()

            Button("Close") { dismiss() }
                .padding(.bottom, 40)
        }
        .navigationTitle("Camera")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CameraView()
            .environment(AppRouter())
    }
}
