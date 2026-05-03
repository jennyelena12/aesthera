//
//  GuidelineConvert.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 04/05/26.
//

import Foundation
import SwiftUI
import PencilKit

struct GuidelineConvert {
    static func convertToDrawing(faces: [CleanFaceData],
                                 drawnSize: CGSize,
                                 offsetPoint: CGPoint,
                                 color: UIColor = .black,
                                 width: CGFloat = 2.0) -> PKDrawing {
        var strokes: [PKStroke] = []
        
        for face in faces {
            let metrics = FaceMetrics(face: face, drawnSize: drawnSize, offsetPoint: offsetPoint)
            let shapes = metrics.exportAsPencilKitShape()
            let stroke = shapes.map { $0.asPKStroke(color: color, width: width) }
            strokes.append(contentsOf: stroke)
        }
        
        return PKDrawing(strokes: strokes)
    }
}
