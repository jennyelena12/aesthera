//
//  DrawingCanvasView.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 03/05/26.
//

import SwiftUI
import PencilKit

struct PKCanvasRepresentable: UIViewRepresentable {
    
    @Binding var canvasView: PKCanvasView
    let tool: DrawingTool
    let lineWidth: CGFloat

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.overrideUserInterfaceStyle = .light
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

struct DrawingCanvasView: View {
    let originalImage: UIImage
    let faceObservations: [CleanFaceData]

    @Environment(\.dismiss) private var dismiss
    @State private var canvasView       = PKCanvasView()
    @State private var selectedTool     : DrawingTool = .pen
    @State private var penThickness     : CGFloat = 5
    @State private var eraserThickness  : CGFloat = 20
    @State private var showImage        = true
    @State private var showGuides       = true
    @State private var showSaveAlert    = false

    private var thickness: CGFloat { selectedTool == .pen ? penThickness : eraserThickness }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                canvasWithTools.padding(20)
                Spacer()
                thicknessSlider.padding(.horizontal, 40).padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { navBar }
        .alert("Saved to Photos!", isPresented: $showSaveAlert) { Button("OK") {} }
    }

    private var canvasWithTools: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = width * 1.3

            ZStack {
                canvasLayers
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
                    )
                toolImage("pencil", tool: .pen)
                    .frame(width: width * 0.5, height: width * 0.5)
                    .frame(width: width, height: height, alignment: .bottomLeading)
                    .offset(x: -width * 0.06, y: width * 0.28)
                toolImage("eraser", tool: .eraser)
                    .frame(width: width * 0.5, height: width * 0.5)
                    .frame(width: width, height: height, alignment: .bottomTrailing)
                    .offset(x: width * 0.06, y: width * 0.28)
            }
            .frame(width: width, height: height * 1.35)
        }
        .aspectRatio(1 / 1.35, contentMode: .fit)
    }

    private var canvasLayers: some View {
        ZStack {
            if showImage {
                Image(uiImage: originalImage)
                    .resizable().scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if showGuides {
                FaceLandmarkOverlay(imageSize: originalImage.size, observations: faceObservations)
            }
            PKCanvasRepresentable(canvasView: $canvasView, tool: selectedTool, lineWidth: thickness)
        }
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
            Button { showImage.toggle() } label: {
                Image(systemName: showImage ? "eye.fill" : "eye.slash.fill")
            }.tint(showImage ? .accentColor : .secondary)

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
        let renderer = ImageRenderer(content: exportView)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            showSaveAlert = true
        }
    }

    private var exportView: some View {
        ZStack {
            Color.white
            if showImage { Image(uiImage: originalImage).resizable().scaledToFit() }
            if showGuides {
                FaceLandmarkOverlay(imageSize: originalImage.size, observations: faceObservations)
            }
            Image(uiImage: canvasView.drawing.image(
                from: canvasView.drawing.bounds, scale: UIScreen.main.scale)
            ).resizable().scaledToFit()
        }
        .frame(width: 1024, height: 1024)
    }
}
