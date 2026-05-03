//
//  AdjustableGuidelineOverlay.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 03/05/26.
//

import Foundation
import SwiftUI

struct AdjustableGuidelineOverlay: View {
    let imageSize: CGSize
    @Binding var face: CleanFaceData
    var lineWidth: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let scale = min(geo.size.width / imageSize.width, geo.size.height / imageSize.height)
            let drawnWidth = imageSize.width * scale
            let drawnHeight = imageSize.height * scale
            
            let offsetX = (geo.size.width - drawnWidth) / 2
            let offsetY = (geo.size.height - drawnHeight) / 2
            
            ZStack {
                Canvas { context, size in
                    let metrics = FaceMetrics(face: face,
                                drawnSize: CGSize(width: drawnWidth, height: drawnHeight),
                                offsetPoint: CGPoint(x: offsetX, y: offsetY))
                
                    context.stroke(metrics.getCraniumPath(), with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    context.stroke(metrics.getCenterAxisPath(), with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    context.stroke(metrics.getEyePath(top: true), with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    context.stroke(metrics.getEyePath(top: false), with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    context.stroke(metrics.getChinPath(), with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    
                }
                
                let nodes: [(binding: Binding<AnchorPoint>, color: Color)] = [
                    ($face.chin, .orange),
                    ($face.mouth, .orange),
                    ($face.leftSide, .orange),
                    ($face.rightSide, .orange),
                    ($face.leftEyeTop, .orange),
                    ($face.leftEyeBottom, .orange),
                    ($face.rightEyeTop, .orange),
                    ($face.rightEyeBottom, .orange)
                ]
                
                ForEach(0..<nodes.count, id: \.self) { index in
                    DraggableNode(
                        point: nodes[index].binding,
                        drawnWidth: drawnWidth,
                        drawnHeight: drawnHeight,
                        offsetX: offsetX,
                        offsetY: offsetY,
                        color: nodes[index].color
                    )
                    
                }
                
            }
            
        }
        
    }
}

