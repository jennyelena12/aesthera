//
//  DrawingCanvasLayer.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//

import SwiftUI

// This component draws all strokes for ONE layer
struct DrawingCanvasLayer: View {

    let layer: DrawingLayer
    var currentStroke: DrawingStroke? = nil  // the stroke being drawn right now

    var body: some View {
        Canvas { context, size in

            // Draw all saved strokes
            for stroke in layer.strokes {
                drawStroke(stroke, in: &context)
            }

            // Draw the live stroke (finger still on screen)
            if let live = currentStroke {
                drawStroke(live, in: &context)
            }
        }
    }

    // Helper: draws a single stroke using its points
    private func drawStroke(_ stroke: DrawingStroke, in context: inout GraphicsContext) {
        guard stroke.points.count > 1 else { return }

        var path = Path()
        path.move(to: stroke.points[0])

        for point in stroke.points.dropFirst() {
            path.addLine(to: point)
        }

        context.stroke(
            path,
            with: .color(stroke.color.opacity(stroke.opacity)),
            style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round)
        )
    }
}
