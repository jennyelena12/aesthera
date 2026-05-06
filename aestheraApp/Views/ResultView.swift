//
//  ResultView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI
import Photos
import SwiftData


struct ResultView: View {

    let image: UIImage
    let faces: [CleanFaceData]

    @Environment(AppRouter.self) private var router

    @State private var resultFaces: [CleanFaceData] = []


    @State private var lineOpacity: Double = 1.0


    @State private var lowOpacityReference: Bool = false


    @State private var showSavedAlert = false
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showSaveConfirmation = false

    var body: some View {
        VStack(spacing: 16) {

            // --- Image + adjustable proportion overlay ---
            imageWithOverlay
                .padding(.horizontal)

            // --- Controls (slider + toggle) ---
            controls
                .padding(.horizontal)

            Spacer()

            // --- Bottom action buttons ---
            actionButtons
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if resultFaces.isEmpty {
                resultFaces = faces
            }
        }
        .alert("Saved to Photos!", isPresented: $showSavedAlert) {
            Button("OK") {}
        }
        .alert("Saved to My Works", isPresented: $showSaveConfirmation) {
            Button("OK") {}
        }
    }

    // MARK: - Subviews

    private var imageWithOverlay: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .opacity(lowOpacityReference ? 0.3 : 1.0)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            ForEach($resultFaces.indices, id: \.self) { idx in
                AdjustableGuidelineOverlay(
                    imageSize: image.size,
                    face: $resultFaces[idx],
                    lineWidth: 2.0
                )
                .opacity(lineOpacity)
            }
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Line Opacity")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(lineOpacity * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Slider(value: $lineOpacity, in: 0...1)
            }

            Toggle("Dim reference photo", isOn: $lowOpacityReference)
                .font(.subheadline)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Menu {
                Button {
                    saveOverlayImage()
                } label: {
                    Label("With photo (JPEG)", systemImage: "photo")
                }
                Button {
                    saveLinesOnlyAsPNG()
                } label: {
                    Label("Lines only (transparent PNG)", systemImage: "scribble.variable")
                }
            } label: {
                Label("Download", systemImage: "arrow.down.to.line")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)

            // IMPORTANT: copy adjusted faces back onto the router before pushing canvas, so DrawingCanvasView gets the user's tweaked anchor positions, not the originally-detected ones.
            Button {
                router.detectedFaces = resultFaces
                router.openCanvas()
            } label: {
                Label("Draw on Canvas", systemImage: "paintpalette.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                saveToWorks()
            } label: {
                Label("Save", systemImage: "bookmark")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Save logic

    /// Mode A — composite of dimmed photo + lines, baked onto a white
    /// background, saved as JPEG via UIImageWriteToSavedPhotosAlbum.
    /// Useful when the user wants a single self-contained reference image.
    private func saveOverlayImage() {
        let exportView = ZStack {
            Color.white
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .opacity(lowOpacityReference ? 0.3 : 1.0)
            FaceLandmarkOverlay(
                imageSize: image.size,
                observations: resultFaces
            )
            .opacity(lineOpacity)
        }
        .frame(width: 1024, height: 1024)

        let renderer = ImageRenderer(content: exportView)
        renderer.scale = UIScreen.main.scale
        if let result = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
            showSavedAlert = true
        }
    }
    
    private func saveToWorks() {
        let store = SavedScanStore(context: modelContext)
        let saved = store.save(
            image: image,
            faces: resultFaces,
            source: "scan"   // change to "camera" / "library" / "curated" later if you track it
        )
        if saved != nil {
            showSaveConfirmation = true
        }
    }


    private func saveLinesOnlyAsPNG() {
        let exportView = FaceLandmarkOverlay(
            imageSize: image.size,
            observations: resultFaces
        )
        .opacity(lineOpacity)
        .frame(width: image.size.width, height: image.size.height)

        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 1

        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData() else {
            return
        }

        savePNGToPhotos(pngData)
    }


    private func savePNGToPhotos(_ data: Data) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { success, _ in
                if success {
                    DispatchQueue.main.async {
                        showSavedAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(
            image: UIImage(systemName: "person.crop.square") ?? UIImage(),
            faces: []
        )
        .environment(AppRouter())
    }
}
