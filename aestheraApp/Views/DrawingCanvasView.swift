//
//  DrawingCanvasView.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 03/05/26.
//

import SwiftUI
import PencilKit

enum DrawingTool {
    case pen
    case eraser
}

struct PKCanvasRepresentable: UIViewRepresentable {

    @Binding var canvasView: PKCanvasView
    let tool: DrawingTool
    let lineWidth: CGFloat

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque        = false
        canvasView.drawingPolicy   = .anyInput
        canvasView.overrideUserInterfaceStyle = .light

        canvasView.isScrollEnabled = false
        canvasView.contentInset    = .zero
        canvasView.contentOffset   = .zero

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        switch tool {
        case .pen:
            uiView.tool = PKInkingTool(.pencil, color: .black, width: lineWidth)
        case .eraser:
            uiView.tool = PKEraserTool(.bitmap, width: lineWidth)
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
    @State private var selectedTool     : DrawingTool = .pen
    @State private var penThickness     : CGFloat = 5
    @State private var eraserThickness  : CGFloat = 20
    @State private var showThumbnail        = true
    @State private var showGuides       = true
    @State private var showSaveAlert    = false

    @State private var zoomScale     : CGFloat = 1.0
    @State private var baseZoomScale : CGFloat = 1.0
    private var thickness: CGFloat { selectedTool == .pen ? penThickness : eraserThickness }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                thicknessSlider
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                canvasWithTools
                    .padding(.top, 20)

                Spacer()
                    .frame(height: 110)
            }

            bottomTools
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar { navBar }
        .alert("Saved to Photos!", isPresented: $showSaveAlert) { Button("OK") {} }
    }

    private var canvasWithTools: some View {
        canvasLayers
            .frame(width: 350, height: 500)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var bottomTools: some View {
        GeometryReader { geo in
            HStack(spacing: -90) {

                toolImage("pencil", tool: .pen)
                    .frame(width: 180, height: 180)

                toolImage("eraser", tool: .eraser)
                    .frame(width: 180, height: 180)
            }
            .position(
                x: 120,
                y: geo.size.height - 20
            )
        }
        .ignoresSafeArea()
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
                tool: selectedTool,
                lineWidth: thickness
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
    private func toolImage(_ name: String, tool: DrawingTool) -> some View {
        let isActive = selectedTool == tool
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) { selectedTool = tool }
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
                Text(selectedTool == .pen ? "Pen size" : "Eraser size")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(thickness)) pt")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            if selectedTool == .pen {
                Slider(value: $penThickness, in: 1...30, step: 1).tint(.black)
            } else {
                Slider(value: $eraserThickness, in: 5...60, step: 1).tint(.gray)
            }
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

        let canvasSize = CGSize(width: 350, height: 500)

        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        let scale = canvasSize.width / guideCanvasView.bounds.width

        let exported = renderer.image { ctx in

            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: canvasSize))

            let guideImage = guideCanvasView.drawing.image(
                from: guideCanvasView.bounds,
                scale: scale
            )

            guideImage.draw(in: CGRect(origin: .zero, size: canvasSize))

            let drawingImage = canvasView.drawing.image(
                from: canvasView.bounds,
                scale: scale
            )

            drawingImage.draw(in: CGRect(origin: .zero, size: canvasSize))
        }

        UIImageWriteToSavedPhotosAlbum(exported, nil, nil, nil)

        showSaveAlert = true
    }
}
