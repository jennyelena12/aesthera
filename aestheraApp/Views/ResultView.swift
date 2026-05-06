//
//  ResultView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI
import Photos


struct ResultView: View {

    let image: UIImage
    let faces: [CleanFaceData]

    @Environment(AppRouter.self) private var router

    @State private var resultFaces: [CleanFaceData] = []


    @State private var lineOpacity: Double = 1.0


    @State private var lowOpacityReference: Bool = false


    @State private var showSavedAlert = false

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

    /// Mode B — overlay strokes only, on a transparent background,
    /// saved as PNG. Rendered at the original image's pixel dimensions
    /// so the user can drop this PNG on top of the source photo in any
    /// image editor and the lines line up 1:1.
    ///
    /// We can't use UIImageWriteToSavedPhotosAlbum here — that helper
    /// flattens alpha and would bake whatever's behind the image (often
    /// black) into the saved file. PHPhotoLibrary lets us write raw PNG
    /// data so the alpha channel is preserved.
    private func saveLinesOnlyAsPNG() {
        let exportView = FaceLandmarkOverlay(
            imageSize: image.size,
            observations: resultFaces
        )
        .opacity(lineOpacity)
        .frame(width: image.size.width, height: image.size.height)

        let renderer = ImageRenderer(content: exportView)
        // We're already requesting the frame at native pixel size, so
        // scale = 1 keeps the output at exactly image.size pixels.
        renderer.scale = 1

        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData() else {
            return
        }

        savePNGToPhotos(pngData)
    }

    /// Writes raw PNG bytes (alpha intact) to the user's Photos library.
    /// Requires NSPhotoLibraryAddUsageDescription in Info.plist.
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
        // Preview won't have real face data, but this lets us see the layout shell.
        ResultView(
            image: UIImage(systemName: "person.crop.square") ?? UIImage(),
            faces: []
        )
        .environment(AppRouter())
    }
}
