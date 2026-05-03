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
                    let makeCGPoint = { (p: AnchorPoint) -> CGPoint in
                        CGPoint(x: p.x * drawnWidth + offsetX, y: p.y * drawnHeight + offsetY)
                    }
                    
                    let chin = makeCGPoint(face.chin)
                    let nose = makeCGPoint(face.nose)
                    let leftEyeTop = makeCGPoint(face.leftEyeTop)
                    let leftEyeBottom = makeCGPoint(face.leftEyeBottom)
                    let rightEyeTop = makeCGPoint(face.rightEyeTop)
                    let rightEyeBottom = makeCGPoint(face.rightEyeBottom)
                    let leftSide = makeCGPoint(face.leftSide)
                    let rightSide = makeCGPoint(face.rightSide)
                    
                    let leftEyeCenter = CGPoint(x: (leftEyeTop.x + leftEyeBottom.x) / 2, y: (leftEyeTop.y + leftEyeBottom.y) / 2)
                    let rightEyeCenter = CGPoint(x: (rightEyeTop.x + rightEyeBottom.x) / 2, y: (rightEyeTop.y + rightEyeBottom.y) / 2)
                    let eyeMid = CGPoint(x: (leftEyeCenter.x + rightEyeCenter.x) / 2, y: (leftEyeCenter.y + rightEyeCenter.y) / 2)
                    
                    let lowerFaceHeight = abs(chin.y - eyeMid.y)
                    let pitchDelta = (eyeMid.y + (lowerFaceHeight * 0.5)) - nose.y
                    let noseDrop = abs(nose.y - eyeMid.y) + (pitchDelta * 0.6)
                    let noseRatio = min(max(lowerFaceHeight > 0 ? (noseDrop / lowerFaceHeight) : 0.5, 0.4), 0.9)
                    
                    let leftDist = abs(leftSide.x - eyeMid.x)
                    let rightDist = abs(rightSide.x - eyeMid.x)
                    
                    var latDX = (leftDist > rightDist ? leftSide.x : rightSide.x) - (leftDist > rightDist ? rightSide.x : leftSide.x)
                    var latDY = (leftDist > rightDist ? leftSide.y : rightSide.y) - (leftDist > rightDist ? rightSide.y : leftSide.y)
                    let latLen = hypot(latDX, latDY)
                    
                    if latLen > 0 { latDX /= latLen; latDY /= latLen }
                    
                    let maxDist = max(leftDist, rightDist)
                    let yawIntensity = maxDist > 0 ? 1.0 - (min(leftDist, rightDist) / maxDist) : 0
                    let eyeAngle = atan2(rightEyeCenter.y - leftEyeCenter.y, rightEyeCenter.x - leftEyeCenter.x)
                    
                    let cranialRadius = (maxDist * 1.10 * (1.0 - yawIntensity)) + (((0.6 + (noseRatio * 0.4)) * lowerFaceHeight) * yawIntensity)
                    let cranialCenter = CGPoint(
                        x: eyeMid.x + (latDX * cranialRadius * yawIntensity * 0.9),
                        y: eyeMid.y - (cranialRadius * (0.3 + (noseRatio * 0.35))) + (pitchDelta * 0.35) + (latDY * cranialRadius * yawIntensity * 0.9)
                    )
                    
                    var cranialPath = Path()
                    cranialPath.addArc(center: cranialCenter, radius: cranialRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                    context.stroke(cranialPath, with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    
                    let dist = hypot(eyeMid.x - chin.x, eyeMid.y - chin.y)
                    let len = dist + (cranialRadius * 2.0)
                    
                    var centerLine = Path()
                    centerLine.move(to: chin)
                    centerLine.addLine(to: CGPoint(x: chin.x + ((eyeMid.x - chin.x) / dist) * len, y: chin.y + ((eyeMid.y - chin.y) / dist) * len))
                    context.stroke(centerLine, with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    
                    var upperEye = Path()
                    var lowerEye = Path()
                    upperEye.move(to: CGPoint(x: leftEyeTop.x - cos(eyeAngle) * 25.0, y: leftEyeTop.y - sin(eyeAngle) * 25.0))
                    upperEye.addLine(to: CGPoint(x: rightEyeTop.x + cos(eyeAngle) * 25.0, y: rightEyeTop.y + sin(eyeAngle) * 25.0))
                    lowerEye.move(to: CGPoint(x: leftEyeBottom.x - cos(eyeAngle) * 25.0, y: leftEyeBottom.y - sin(eyeAngle) * 25.0))
                    lowerEye.addLine(to: CGPoint(x: rightEyeBottom.x + cos(eyeAngle) * 25.0, y: rightEyeBottom.y + sin(eyeAngle) * 25.0))
                    
                    context.stroke(upperEye, with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    context.stroke(lowerEye, with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    
                    var chinLine = Path()
                    chinLine.move(to: CGPoint(x: chin.x - cos(eyeAngle) * 15.0, y: chin.y - sin(eyeAngle) * 15.0))
                    chinLine.addLine(to: CGPoint(x: chin.x + cos(eyeAngle) * 15.0, y: chin.y + sin(eyeAngle) * 15.0))
                    context.stroke(chinLine, with: .color(.red.opacity(0.8)), lineWidth: 1.5)
                    
                }
                
                let nodes: [(binding: Binding<AnchorPoint>, color: Color)] = [
                    ($face.chin, .orange),
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

