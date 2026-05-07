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
    // 1. Add the drawingScale property with a default of 1.0
    var drawingScale: CGFloat = 1.0
    
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / imageSize.width, size.height / imageSize.height)
            let offsetX = (size.width - imageSize.width * scale) / 2
            let offsetY = (size.height - imageSize.height * scale) / 2
            
            let makeCGPoint = { (p: AnchorPoint) -> CGPoint in
                CGPoint(x: p.x * scale * imageSize.width + offsetX,
                        y: p.y * scale * imageSize.height + offsetY)
            }
            
            // 2. Scale the anchor dots
            func drawAnchor(_ point: CGPoint, color: Color, in context: inout GraphicsContext) {
                let dotSize = 6 * drawingScale
                let rect = CGRect(x: point.x - (dotSize/2), y: point.y - (dotSize/2), width: dotSize, height: dotSize)
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }
            
            // 3. Scale the labels and their offsets
            func drawLabel(_ text: String, _ point: CGPoint, color: Color, in context: inout GraphicsContext) {
                let fontSize = 10 * drawingScale
                // Only draw labels if they are large enough to be readable
                if fontSize > 3 {
                    let resolved = context.resolve(
                        Text(text)
                            .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                            .foregroundStyle(color)
                    )
                    context.draw(resolved, at: CGPoint(x: point.x, y: point.y - (8 * drawingScale)), anchor: .bottom)
                }
            }
            
            for face in observations {
                // ... (Keep all your existing math logic the same) ...
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
                
                // 4. Scale the Stroke Widths
                let lineWidth = 1.5 * drawingScale
                
                var cranialPath = Path()
                cranialPath.addArc(center: cranialCenter, radius: cranialRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                context.stroke(cranialPath, with: .color(.red.opacity(0.8)), lineWidth: lineWidth)
                
                let dist = hypot(eyeMid.x - chin.x, eyeMid.y - chin.y)
                let len = dist + (cranialRadius * 2.0)
                
                var centerLine = Path()
                centerLine.move(to: chin)
                centerLine.addLine(to: CGPoint(x: chin.x + ((eyeMid.x - chin.x) / dist) * len, y: chin.y + ((eyeMid.y - chin.y) / dist) * len))
                context.stroke(centerLine, with: .color(.red.opacity(0.8)), lineWidth: lineWidth)
                
                // Scale the horizontal line extensions (the 25.0 and 15.0 values)
                let eyeExt = 25.0 * drawingScale
                let chinExt = 15.0 * drawingScale
                
                var upperEye = Path()
                var lowerEye = Path()
                upperEye.move(to: CGPoint(x: leftEyeTop.x - cos(eyeAngle) * eyeExt, y: leftEyeTop.y - sin(eyeAngle) * eyeExt))
                upperEye.addLine(to: CGPoint(x: rightEyeTop.x + cos(eyeAngle) * eyeExt, y: rightEyeTop.y + sin(eyeAngle) * eyeExt))
                lowerEye.move(to: CGPoint(x: leftEyeBottom.x - cos(eyeAngle) * eyeExt, y: leftEyeBottom.y - sin(eyeAngle) * eyeExt))
                lowerEye.addLine(to: CGPoint(x: rightEyeBottom.x + cos(eyeAngle) * eyeExt, y: rightEyeBottom.y + sin(eyeAngle) * eyeExt))
                
                context.stroke(upperEye, with: .color(.red.opacity(0.8)), lineWidth: lineWidth)
                context.stroke(lowerEye, with: .color(.red.opacity(0.8)), lineWidth: lineWidth)
                
                var chinLine = Path()
                chinLine.move(to: CGPoint(x: chin.x - cos(eyeAngle) * chinExt, y: chin.y - sin(eyeAngle) * chinExt))
                chinLine.addLine(to: CGPoint(x: chin.x + cos(eyeAngle) * chinExt, y: chin.y + sin(eyeAngle) * chinExt))
                context.stroke(chinLine, with: .color(.red.opacity(0.8)), lineWidth: lineWidth)
                
                drawLabel("Chin", CGPoint(x: chin.x + cos(eyeAngle) * chinExt, y: chin.y + sin(eyeAngle) * chinExt), color: .red, in: &context)
                drawLabel("Eyes", CGPoint(x: rightEyeTop.x + cos(eyeAngle) * eyeExt, y: rightEyeTop.y + sin(eyeAngle) * eyeExt), color: .red, in: &context)

                let anchors = [chin, leftEyeCenter, leftEyeTop, leftEyeBottom, leftSide, rightSide, rightEyeCenter, rightEyeTop, rightEyeBottom]
                anchors.forEach { drawAnchor($0, color: .orange, in: &context) }
            }
        }
    }
}
