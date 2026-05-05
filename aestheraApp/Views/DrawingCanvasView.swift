//
//  DrawingCanvasView.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 04/05/26.
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
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
