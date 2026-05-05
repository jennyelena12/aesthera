//
//  ResultView.swift
//  aestheraApp
//

import SwiftUI

// PRD coverage (MVP):
//   ✓ Proportion lines overlay     → AdjustableGuidelineOverlay
//   ✓ Opacity slider               → lineOpacity
//   ✓ On/Off low-opacity reference → lowOpacityReference
//   ✓ Download button              → saveOverlayImage()
//   ✓ Draw on Canvas button        → router.openCanvas()
//
// Stage 2:
//   - Custom toolbar with tutorial button
//   - Final Figma styling
//
// Layout is intentionally plain — once the Figma is locked, the visual
// swap is mostly Stack restructuring + asset replacement. Logic and
// bindings here should NOT need to change.

struct ResultView: View {

    let image: UIImage
    let faces: [CleanFaceData]

    @Environment(AppRouter.self) private var router

    // The faces are kept as @State so the AdjustableGuidelineOverlay
    // can mutate them via @Binding (drag the orange anchor nodes around).
    // We seed this from the `faces` argument in .onAppear.
    @State private var resultFaces: [CleanFaceData] = []

    // Opacity slider value for the proportion lines (0 = invisible, 1 = solid).
    @State private var lineOpacity: Double = 1.0

    // When ON, the underlying photo is dimmed so the proportion lines pop.
    @State private var lowOpacityReference: Bool = false

    // Confirmation alert after the Download button saves to Photos.
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
            // Copy the detected faces into mutable state once.
            // (We don't overwrite on every appear — the user may have
            // already nudged anchor nodes and we don't want to reset them.)
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

            // One overlay per detected face. .opacity() applied here
            // tints all the proportion lines AND the draggable nodes.
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

            // Opacity slider
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

            // On/Off low-opacity reference toggle
            Toggle("Dim reference photo", isOn: $lowOpacityReference)
                .font(.subheadline)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                saveOverlayImage()
            } label: {
                Label("Download", systemImage: "arrow.down.to.line")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)

            // IMPORTANT: copy adjusted faces back onto the router before
            // pushing canvas, so DrawingCanvasView gets the user's tweaked
            // anchor positions, not the originally-detected ones.
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

    // Renders the current view (image + proportion overlay, respecting
    // the opacity slider and dim-reference toggle) to a UIImage and
    // writes it to the user's Photos library.
    //
    // We use FaceLandmarkOverlay here (not AdjustableGuidelineOverlay)
    // because it draws cleanly without the orange draggable nodes,
    // which the user does not want baked into a saved image.
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
