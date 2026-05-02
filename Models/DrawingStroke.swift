//
//  DrawingStroke.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//
import SwiftUI

// A single stroke = one finger drag on screen
struct DrawingStroke {
    var points: [CGPoint]   // all the points the finger passed through
    var color: Color
    var lineWidth: CGFloat
    var opacity: Double
    var isEraser: Bool      // if true, draws in white (erases)
}
