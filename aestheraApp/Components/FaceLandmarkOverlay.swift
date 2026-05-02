//
//  FaceDetectedOverlay.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 03/05/26.
//

import Foundation
import SwiftUI
import Vision

struct FaceLandmarkOverlay: View {
    let imageSize: CGSize
    let observations: [CleanFaceData]
    
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / imageSize.width, size.height / imageSize.height)
            let offsetX = (size.width - imageSize.width * scale) / 2
            let offsetY = (size.height - imageSize.height * scale) / 2
            
            let makeCGPoint = { (p: AnchorPoint) -> CGPoint in
                CGPoint(x: p.x * scale * imageSize.width + offsetX,
                        y: p.y * scale * imageSize.height + offsetY)
            }
            
            func drawAnchor(_ point: CGPoint, color: Color, in context: inout GraphicsContext) {
                let rect = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }
            
            func drawLabel(_ text: String, _ point: CGPoint, color: Color, in context: inout GraphicsContext) {
                let resolved = context.resolve(
                    Text(text).font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(color)
                )
                context.draw(resolved, at: CGPoint(x: point.x, y: point.y - 8), anchor: .bottom)
            }
            
            for face in observations {
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
                
                drawLabel("Chin", CGPoint(x: chin.x + cos(eyeAngle) * 15.0, y: chin.y + sin(eyeAngle) * 15.0), color: .red, in: &context)
                drawLabel("Eyes", CGPoint(x: rightEyeTop.x + cos(eyeAngle) * 25.0, y: rightEyeTop.y + sin(eyeAngle) * 25.0), color: .red, in: &context)

                
                let anchors = [chin, leftEyeCenter, leftEyeTop, leftEyeBottom, leftSide, rightSide, rightEyeCenter, rightEyeTop, rightEyeBottom]
                anchors.forEach { drawAnchor($0, color: .orange, in: &context) }
            }
        }
    }
}

