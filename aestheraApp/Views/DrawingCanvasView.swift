//
//  DrawingCanvasView.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 04/05/26.
//

import SwiftUI
import PencilKit

struct PKCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isDrawingMode: Bool
    @Binding var isEraser: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        
        canvasView.minimumZoomScale = 0.5
        canvasView.maximumZoomScale = 5
        canvasView.bouncesZoom = true
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if isDrawingMode {
            uiView.becomeFirstResponder()
            if isEraser {
                uiView.tool = PKEraserTool(.bitmap)
            } else {
                uiView.tool = PKInkingTool(.pen, color: .black, width: 5)
            }
        } else {
            uiView.resignFirstResponder()
        }
    }
}
    
struct PKGuideCanvasRepresentable: UIViewRepresentable {
    let canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor    = .clear
        canvasView.isOpaque           = false
        canvasView.isScrollEnabled    = false
        canvasView.contentInset       = .zero
        canvasView.contentOffset      = .zero
        canvasView.isUserInteractionEnabled = false
        canvasView.overrideUserInterfaceStyle = .light
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct DrawingCanvasView: View {
    let originalImage: UIImage
    let faceObservations: [CleanFaceData]

    @Environment(\.dismiss) private var dismiss
    @State private var canvasView       = PKCanvasView()
    @State private var guideCanvasView = PKCanvasView()
    @State private var guidesLoaded    = false
    @State private var penThickness     : CGFloat = 5
    @State private var eraserThickness  : CGFloat = 20
    @State private var showThumbnail        = true
    @State private var showGuides       = true
    @State private var showSaveAlert    = false
    @State private var isDrawingMode = true
    @State private var isEraser = false;
    @State private var zoomScale     : CGFloat = 1.0
    @State private var baseZoomScale : CGFloat = 1.0
    private var thickness: CGFloat { isDrawingMode ? penThickness : eraserThickness }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                thicknessSlider.padding(.horizontal, 20).padding(.vertical, 10)

                canvasWithTools
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar { navBar }
        .alert("Saved to Photos!", isPresented: $showSaveAlert) { Button("OK") {} }
    }

    private var canvasWithTools: some View {
        GeometryReader { geo in
            let imageAspect = originalImage.size.height / originalImage.size.width
            let width = geo.size.width
            let height = width * imageAspect

            ZStack {
                canvasLayers
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                toolImage("pencil", isActive: isDrawingMode)
                    .frame(width: width * 0.5, height: width * 0.5)
                    .frame(width: width, height: height, alignment: .bottomLeading)
                    .offset(x: -width * 0.06, y: width * 0.28)
                toolImage("eraser", isActive: isEraser)
                    .frame(width: width * 0.5, height: width * 0.5)
                    .frame(width: width, height: height, alignment: .bottomTrailing)
                    .offset(x: width * 0.06, y: width * 0.28)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .aspectRatio(1 / 1.35, contentMode: .fit)
    }

    private var canvasLayers: some View {
        ZStack {

            PKGuideCanvasRepresentable(canvasView: guideCanvasView)

            if showThumbnail {
                VStack {
                    HStack {
                        thumbnailView
                            .padding(8)
                        Spacer()
                    }
                    Spacer()
                }
            }

            PKCanvasRepresentable(
                canvasView: $canvasView,
                isDrawingMode: $isDrawingMode,
                isEraser: $isEraser
            )
        }
        .onAppear {
            guard !guidesLoaded else { return }
            DispatchQueue.main.async {
                guard guideCanvasView.bounds.width > 0 else { return }
                let size = guideCanvasView.bounds.size
                let drawing = GuidelineConvert.convertToDrawing(
                    faces: faceObservations,
                    drawnSize: size,
                    offsetPoint: .zero
                )
                guideCanvasView.drawing = drawing
                guidesLoaded = true
            }
        }
        .scaleEffect(zoomScale)
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    zoomScale = min(max(baseZoomScale * value, 0.5), 4.0)
                }
                .onEnded { _ in
                    baseZoomScale = zoomScale
                }
        )
    }
    
    private var thumbnailView: some View {
        ZStack {
            Image(uiImage: originalImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 6))

            FaceLandmarkOverlay(
                imageSize: originalImage.size,
                observations: faceObservations,
                drawingScale: 0.4
            )
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private func toolImage(_ name: String, isActive: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                if name == "pencil" {
                    isDrawingMode = true
                }
                else{
                    isEraser = true
                }
            }
        } label: {
            Image(name)
                .resizable()
                .scaledToFit()
                .opacity(isActive ? 1.0 : 0.45)
                .scaleEffect(isActive ? 1.0 : 0.82)
                .animation(.spring(response: 0.3, dampingFraction: 0.55), value: isActive)
        }
    }

    private var thicknessSlider: some View {
        VStack(spacing: 6) {
            HStack {
                Text(isDrawingMode ? "Pen size" : "Eraser size")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(thickness)) pt")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            let isPen = isDrawingMode
            Slider(value: isPen ? $penThickness : $eraserThickness, in: isPen ? 1...30 : 5...60 , step: 1).tint(isPen ? .black : .gray)
//            if selectedTool == .pen {
//                Slider(value: $penThickness, in: 1...30, step: 1).tint(.black)
//            } else {
//                Slider(value: $eraserThickness, in: 5...60, step: 1).tint(.gray)
//            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ToolbarContentBuilder
    private var navBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").fontWeight(.semibold)
            }
        }
        ToolbarItem(placement: .principal) {
            Text("Canvas").font(.headline)
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button { showThumbnail.toggle() } label: {
                Image(systemName: showThumbnail ? "eye.fill" : "eye.slash.fill")
            }.tint(showThumbnail ? .accentColor : .secondary)

            Button { canvasView.undoManager?.undo() } label: {
                Image(systemName: "arrow.uturn.backward")
            }.disabled(canvasView.undoManager?.canUndo == false)

            Button { canvasView.undoManager?.redo() } label: {
                Image(systemName: "arrow.uturn.forward")
            }.disabled(canvasView.undoManager?.canRedo == false)

            Button { saveToPhotos() } label: {
                ZStack {
                    Circle().fill(Color.accentColor).frame(width: 32, height: 32)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                }
            }
        }
    }

    private func saveToPhotos() {
        let size     = originalImage.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let scale    = size.width / guideCanvasView.bounds.width

        let exported = renderer.image { ctx in

            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let guideImage = guideCanvasView.drawing.image(
                from: guideCanvasView.bounds,
                scale: scale
            )
            guideImage.draw(in: CGRect(origin: .zero, size: size))


            let drawingImage = canvasView.drawing.image(
                from: canvasView.bounds,
                scale: scale
            )
            drawingImage.draw(in: CGRect(origin: .zero, size: size))
        }

        UIImageWriteToSavedPhotosAlbum(exported, nil, nil, nil)
        showSaveAlert = true
    }

}
