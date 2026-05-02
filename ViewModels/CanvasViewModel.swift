//
//  CanvasViewModel.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//
import SwiftUI

// @Observable = SwiftUI watches this class for changes
// (requires iOS 17+, use 'class CanvasViewModel: ObservableObject' for iOS 16)
@Observable
class CanvasViewModel {

    // MARK: - Layers
    var layers: [DrawingLayer] = [DrawingLayer(name: "Layer 1")]
    var activeLayerIndex: Int = 0

    // MARK: - Tool Settings
    var isEraser: Bool = false
    var strokeColor: Color = .black
    var lineWidth: CGFloat = 5
    var opacity: Double = 1.0

    // MARK: - Current stroke being drawn right now
    var currentStroke: DrawingStroke? = nil

    // Shortcut to get the active layer
    var activeLayer: DrawingLayer {
        layers[activeLayerIndex]
    }

    // MARK: - Drawing Actions

    // Called when finger touches screen
    func startStroke(at point: CGPoint) {
        currentStroke = DrawingStroke(
            points: [point],
            color: isEraser ? .white : strokeColor,
            lineWidth: isEraser ? lineWidth * 2 : lineWidth,
            opacity: isEraser ? 1.0 : opacity,
            isEraser: isEraser
        )
    }

    // Called while finger is moving
    func continueStroke(to point: CGPoint) {
        currentStroke?.points.append(point)
    }

    // Called when finger lifts up — save the stroke
    func endStroke() {
        guard let stroke = currentStroke else { return }
        layers[activeLayerIndex].strokes.append(stroke)
        currentStroke = nil
    }

    // MARK: - Layer Actions

    func addLayer() {
        let number = layers.count + 1
        layers.append(DrawingLayer(name: "Layer \(number)"))
        activeLayerIndex = layers.count - 1  // switch to new layer
    }

    func deleteLayer(at index: Int) {
        guard layers.count > 1 else { return }  // always keep 1 layer
        layers.remove(at: index)
        // make sure activeLayerIndex is still valid
        activeLayerIndex = min(activeLayerIndex, layers.count - 1)
    }
}
