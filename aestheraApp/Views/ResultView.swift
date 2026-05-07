//
//  ResultView.swift
//  aestheraApp
//
//  Translated from Figma "All brewed perfectly!" frame.
//  Layout (top → bottom):
//   1. Top row     — circular back button (left) + save button (right)
//   2. Header      — "All brewed perfectly!" title (underlined) + subtitle
//   3. Image card  — eye toggle, image w/ proportion overlay, opacity slider
//   4. Buttons     — Download (secondary) + Draw Now! (primary)
//
//  HIG notes:
//   • Back button replaces the system nav bar back chevron — single, clear
//     way to leave the screen.
//   • Save action moved to top-right (was a third bottom button before).
//     Secondary actions belong in the nav-bar zone per HIG.
//   • Bottom action buttons are 1 primary + 1 secondary, side-by-side. No
//     more than 2 visible CTAs at once = clearer hierarchy.
//

import SwiftUI
import Photos
import SwiftData


struct ResultView: View {

    let image: UIImage
    let faces: [CleanFaceData]

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    // ── Detection state ────────────────────────────────────────────
    @State private var resultFaces: [CleanFaceData] = []

    // ── Display tweaks the user can adjust ─────────────────────────
    @State private var lineOpacity: Double = 1.0
    @State private var lowOpacityReference: Bool = false

    // ── Alert state ────────────────────────────────────────────────
    @State private var showSavedAlert = false
    @State private var showSaveConfirmation = false


    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.l) {

                topRow
                headerText
                imageCard

                Spacer(minLength: Spacing.l)

                actionButtons
            }
            .padding(.horizontal, Spacing.screenH)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.l)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
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


    // MARK: - Sections

    private var topRow: some View {
        HStack {
            // Same circular chrome used everywhere — see Components/CircleIconButton.swift
            CircleIconButton(systemName: "chevron.left") {
                router.popOne()
            }

            Spacer()

            CircleIconButton(systemName: "bookmark") {
                saveToWorks()
            }
        }
    }


    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("All brewed perfectly!")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(Color.textPrimary)
//                .underline(true, color: Color.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("Everything's in place. Your sketch awaits.")
                .font(.subheadline)
                .foregroundColor(Color.textSecondary)
        }
    }


    private var imageCard: some View {
        VStack(spacing: Spacing.m) {

            // Eye toggle in top-left of the card
            HStack {
                Button {
                    lowOpacityReference.toggle()
                } label: {
                    Image(systemName: lowOpacityReference ? "eye.slash" : "eye")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.cardSurface, in: Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                Spacer()
            }

            // Image with adjustable proportion overlay
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .opacity(lowOpacityReference ? 0.3 : 1.0)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                ForEach($resultFaces.indices, id: \.self) { idx in
                    AdjustableGuidelineOverlay(
                        imageSize: image.size,
                        face: $resultFaces[idx],
                        lineWidth: 2.0
                    )
                    .opacity(lineOpacity)
                }
            }

            // Opacity slider with playful ghost icons on either side.
            // NOTE: custom images need .resizable() + .scaledToFit() + .frame()
            // to size correctly. .font() and .foregroundColor() only work on
            // SF Symbols, not raster assets.
            HStack(spacing: Spacing.m) {
                Image("pacman")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .opacity(0.3)

                Slider(value: $lineOpacity, in: 0...1)
                    .tint(Color.brandNavy)

                Image("pacman")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .opacity(0.9)
            }
            .padding(.horizontal, 4)
        }
        .padding(Spacing.l)
        .background(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }


    private var actionButtons: some View {
        HStack(spacing: Spacing.m) {

            // Secondary — Download (menu with JPEG / PNG options)
            Menu {
                Button {
                    saveOverlayImage()
                } label: {
                    Label("With photo (JPEG)", systemImage: "photo")
                }
                Button {
                    saveLinesOnlyAsPNG()
                } label: {
                    Label("Lines only (PNG)", systemImage: "scribble.variable")
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.to.line")
                    Text("Download")
                }
                .font(.body.weight(.semibold))
                .foregroundColor(Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.cardSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
            }

            // Primary — Draw Now!
            Button {
                router.detectedFaces = resultFaces
                router.openCanvas()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paintpalette.fill")
                    Text("Draw Now!")
                }
                .font(.body.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.brandNavy)
                )
            }
        }
    }


    // MARK: - Save logic (unchanged from before)

    /// Composite of dimmed photo + lines, baked onto a white background,
    /// saved as JPEG via UIImageWriteToSavedPhotosAlbum.
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
            source: "scan"
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
