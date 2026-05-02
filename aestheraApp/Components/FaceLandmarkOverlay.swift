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
    let viewSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            let widthRatio = size.width / imageSize.width
            let heightRatio = size.height / imageSize.height
            let scale: CGFloat = min(widthRatio, heightRatio)
            
            let offsetX = (size.width - imageSize.width * scale) / 2
            let offsetY = (size.height - imageSize.height * scale) / 2
            
            let makeCGPoint = { (p: AnchorPoint) -> CGPoint in
                CGPoint(x: p.x * scale + offsetX, y: p.y * scale + offsetY)
            }
            
            func drawAnchor(_ point: CGPoint, color: Color, in context: inout GraphicsContext) {
                let rect = CGRect(x: point.x, y: point.y, width: 6, height: 6)
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }
            
            func drawLabel(_ text: String, _ point: CGPoint, color: Color, in context: inout GraphicsContext) {
                let resolvedText = context.resolve(
                    Text(text)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(color)
                )
                context.draw(resolvedText,
                             at: CGPoint(x: point.x, y: point.y - 8),
                             anchor: .bottom)
            }
            
            for observation in observations {
                let chin = makeCGPoint(observation.chin)
                let nose = makeCGPoint(observation.nose)
                let mouth = makeCGPoint(observation.mouth)
                let left_eye_bottom = makeCGPoint(observation.left_eye_bottom)
                let left_eye_top = makeCGPoint(observation.left_eye_top)
                let right_eye_bottom = makeCGPoint(observation.right_eye_bottom)
                let right_eye_top = makeCGPoint(observation.right_eye_top)
                
                let left_side = makeCGPoint(observation.left_side)
                let right_side = makeCGPoint(observation.right_side)
                
                
                let leftEyeCenter = CGPoint(x: (left_eye_top.x + left_eye_bottom.x) / 2, y: (left_eye_top.y + left_eye_bottom.y) / 2)
                let rightEyeCenter = CGPoint(x: (right_eye_top.x + right_eye_bottom.x) / 2, y: (right_eye_top.y + right_eye_bottom.y) / 2)
                let eyeMidPoint = CGPoint(x: (leftEyeCenter.x + rightEyeCenter.x) / 2, y: (leftEyeCenter.y + rightEyeCenter.y) / 2)
                
                
                let lowerFaceHeight = abs(chin.y - eyeMidPoint.y)
                let expectedNoseY = eyeMidPoint.y + (lowerFaceHeight * 0.5)
                let pitchDelta = expectedNoseY - nose.y

                let nosedrop = abs(nose.y - eyeMidPoint.y) + (pitchDelta * 0.6)
                
                
                let rawNoseRatio = lowerFaceHeight > 0 ? (nosedrop/lowerFaceHeight) : 0.5
                let noseRatio = min(max(rawNoseRatio, 0.4), 0.9)
                
                let leftDist = abs(left_side.x - eyeMidPoint.x)
                let rightDist = abs(right_side.x - eyeMidPoint.x)
                
                let rearSilhouette = leftDist > rightDist ? left_side : right_side
                let frontSilhouette = leftDist > rightDist ? right_side : left_side
                
                var lateralDX = rearSilhouette.x - frontSilhouette.x
                var lateralDY = rearSilhouette.y - frontSilhouette.y
                
                let lateralLen = hypot(lateralDX, lateralDY)
                if lateralLen > 0 { lateralDX /= lateralLen; lateralDY /= lateralLen }
                
                // the larger it is, the more non-forward face it is. itisitisitisis
                let maxDist = max(leftDist, rightDist)
                let minDist = min(leftDist, rightDist)
                let yawIntensity = maxDist > 0 ? 1.0 - (minDist / maxDist) : 0
                                
                // to approximate the vertical size due to to difference of nose to chin distance in multiple artstyle.
                let verticalRadius = (0.6 + (noseRatio * 0.4)) * lowerFaceHeight
                let horizontalRadius = maxDist * 1.10
                let cranialRadius = (horizontalRadius * (1.0 - yawIntensity) + (verticalRadius * yawIntensity))
                
                let verticalLiftMultiplier = (0.3 + (noseRatio * 0.35))
                let verticalLift = cranialRadius * verticalLiftMultiplier;
                let lateralOffset = cranialRadius * (yawIntensity * 0.9)
                let pitchCorrection = pitchDelta * 0.35
                
                let cranialCenter = CGPoint(
                    x: eyeMidPoint.x + (lateralDX * lateralOffset),
                    y: eyeMidPoint.y - verticalLift + pitchCorrection + (lateralDY * lateralOffset)
                )
                var cranialPath = Path()
                cranialPath.addArc(center: cranialCenter, radius: cranialRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                context.stroke(cranialPath, with: .color(.red), lineWidth: 2)
                
                var centerLine = Path()
                // take the other side using trigonom
                let dx = eyeMidPoint.x - chin.x
                let dy = eyeMidPoint.y - chin.y
                let dist = hypot(dx, dy)
                
                let len = dist + (cranialRadius * 2.0)
                let endPoint = CGPoint(x: chin.x + (dx/dist) * len,
                                       y: chin.y + (dy/dist) * len)
                
                centerLine.move(to: chin)
                centerLine.addLine(to: endPoint)
                context.stroke(centerLine, with: .color(.red), lineWidth: 2)
                
                let eyeAngle = atan2(rightEyeCenter.y - leftEyeCenter.y, rightEyeCenter.x - leftEyeCenter.x)
                let extensionLength: CGFloat = 20.0
                
                var upperEyePath = Path()
                var lowerEyePath = Path()
                
                upperEyePath.move(to: CGPoint(x: left_eye_top.x - cos(eyeAngle) * extensionLength, y: left_eye_top.y - sin(eyeAngle) * extensionLength))
                upperEyePath.addLine(to: CGPoint(x: right_eye_top.x + cos(eyeAngle) * extensionLength, y: right_eye_top.y + sin(eyeAngle) * extensionLength))
                
                lowerEyePath.move(to: CGPoint(x: left_eye_bottom.x - cos(eyeAngle) * extensionLength, y: left_eye_bottom.y - sin(eyeAngle) * extensionLength))
                lowerEyePath.addLine(to: CGPoint(x: right_eye_bottom.x + cos(eyeAngle) * extensionLength, y: right_eye_bottom.y + sin(eyeAngle) * extensionLength))
                
                context.stroke(upperEyePath, with: .color(.red), lineWidth: 2)
                context.stroke(lowerEyePath, with: .color(.red), lineWidth: 2)
                
                var chinHighlight = Path()
                let chinWidth: CGFloat = 15.0
                
                chinHighlight.move(to: CGPoint(x: chin.x - cos(eyeAngle) * chinWidth, y: chin.y - sin(eyeAngle) * chinWidth))
                chinHighlight.addLine(to: CGPoint(x: chin.x + cos(eyeAngle) * chinWidth, y: chin.y + sin(eyeAngle) * chinWidth))
                context.stroke(chinHighlight, with: .color(.red), lineWidth: 2)
                
                drawAnchor(chin, color: .orange, in: &context)
                drawAnchor(leftEyeCenter, color: .orange, in: &context)
                drawAnchor(left_eye_top, color: .orange, in: &context)
                drawAnchor(left_eye_bottom, color: .orange, in: &context)
                drawAnchor(left_side, color: .blue, in: &context)
                drawAnchor(right_side, color: .blue, in: &context)
                drawAnchor(rightEyeCenter, color: .orange, in: &context)
                drawAnchor(right_eye_top, color: .orange, in: &context)
                drawAnchor(right_eye_bottom, color: .orange, in: &context)
                
                drawLabel("Chin",
                          CGPoint(x: chin.x + cos(eyeAngle) * chinWidth,
                                          y: chin.y + sin(eyeAngle) * chinWidth),
                          color: .red, in: &context)
                drawLabel("Eyes",
                          CGPoint(x: right_eye_top.x + cos(eyeAngle) * extensionLength,
                                  y: right_eye_top.y + sin(eyeAngle) * extensionLength),
                          color: .red, in: &context)
            
                
            }
            
        }
    }
}


