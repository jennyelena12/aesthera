//
//  FaceModels.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation

enum FaceDetectionState {
    case idle
    case analyzing
    case success([CleanFaceData])
    case noFaceDetected
    case error(String)
}

struct AnchorPoint {
    let x: CGFloat
    let y: CGFloat
    let confidence: Float
}

struct CleanFaceData {
    let chin: AnchorPoint
    let mouth: AnchorPoint
    let nose: AnchorPoint
    let leftSide: AnchorPoint
    let rightSide: AnchorPoint
    
    let leftEyeTop: AnchorPoint
    let rightEyeTop: AnchorPoint
    
    let leftEyeBottom: AnchorPoint
    let rightEyeBottom: AnchorPoint
    
    let boundingBox: CGRect
}
