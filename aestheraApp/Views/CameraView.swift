//
//  CameraView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.

import SwiftUI
import UIKit

struct CameraView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router

    @State private var showPicker = false
    @State private var didHandOff = false

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            if cameraAvailable {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("Opening camera…")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "camera.metering.unknown")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("Camera not available")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Try running on a real device.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button("Close") { dismiss() }
                .padding(.bottom, 40)
        }
        .navigationTitle("Camera")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if cameraAvailable && !didHandOff {
                showPicker = true
            }
        }
        .fullScreenCover(isPresented: $showPicker) {
            CameraPicker(
                onCapture: { image in
                    didHandOff = true
                    showPicker = false
                    router.startScanReplacingTop(with: image)
                },
                onCancel: {
                    showPicker = false
                    dismiss()
                }
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        CameraView()
            .environment(AppRouter())
    }
}
