//
//  FaceModels.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation

enum FaceDetectionState: Equatable {
    case idle
    case analyzing
    case success([CleanFaceData])
    case noFaceDetected
    case error(String)
}

struct AnchorPoint: Equatable {
    var x: CGFloat
    var y: CGFloat
    var confidence: Float
}

struct CleanFaceData: Equatable {
    var chin: AnchorPoint
    var mouth: AnchorPoint
    var nose: AnchorPoint
    var leftSide: AnchorPoint
    var rightSide: AnchorPoint
    
    var leftEyeTop: AnchorPoint
    var rightEyeTop: AnchorPoint
    
    var leftEyeBottom: AnchorPoint
    var rightEyeBottom: AnchorPoint
    
    var boundingBox: CGRect
}
