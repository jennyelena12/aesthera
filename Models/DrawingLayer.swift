//
//  DrawingLayer.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//
import SwiftUI

// A layer = like a transparent sheet of paper
struct DrawingLayer: Identifiable {
    let id = UUID()                    // unique ID so SwiftUI can track it
    var name: String
    var strokes: [DrawingStroke] = []  // all strokes drawn on this layer
    var isVisible: Bool = true
}
