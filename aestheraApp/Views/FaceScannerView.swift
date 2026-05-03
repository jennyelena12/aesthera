//
//  FaceScannerView.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct FaceScannerView: View {
    @State private var viewModel = FaceScannerViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Group {
                                if case .success(let faces) = viewModel.detectionState {
                                    FaceLandmarkOverlay(
                                        imageSize: image.size,
                                        observations: faces
                                    )
                                }
                            }
                        )
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("Select an Image")
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                statusView
                if case .success(let faces) = viewModel.detectionState,
                   let image = viewModel.selectedImage {
                    HStack(spacing: 12) {
                        Button {
                            saveOverlayImage(image: image, faces: faces)
                        } label: {
                            Label("Download", systemImage: "arrow.down.to.line")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)

                        NavigationLink {
                            DrawingCanvasView(
                                originalImage: image,
                                faceObservations: faces
                            )
                        } label: {
                            Label("Draw Now!", systemImage: "paintpalette.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Choose Image")
                        .font(.headline)
                        .padding()
                }
                .padding(.horizontal)
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            viewModel.processSelectedImage(uiImage)
                        }
                    }
                }
            }
            .navigationTitle("Aesthera")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch viewModel.detectionState {
        case .idle:
            Text("Ready to Analyze")
                .foregroundStyle(.secondary)
        case .analyzing:
            ProgressView("Analyzing…")
        case .success(let array):
            Text("\(array.count) Face(s) detected!")
                .foregroundStyle(.green)
                .fontWeight(.semibold)
        case .noFaceDetected:
            Text("No Face Detected :(")
                .foregroundStyle(.orange)
        case .error(let error):
            Text("Error: \(error)")
                .foregroundStyle(.red)
        }
    }

    private func saveOverlayImage(image: UIImage, faces: [CleanFaceData]) {
        let view = ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            FaceLandmarkOverlay(imageSize: image.size, observations: faces)
        }
        .frame(width: 1024, height: 1024)

        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        if let result = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
        }
    }
}
