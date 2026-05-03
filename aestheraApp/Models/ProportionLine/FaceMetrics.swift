//
//  FaceMetrics.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 03/05/26.
//

import Foundation
import SwiftUI

struct FaceMetrics {
    let chin, nose, leftSide, rightSide, mouth: CGPoint
    let leftEyeTop, leftEyeBottom, rightEyeTop, rightEyeBottom: CGPoint
    
    let eyeMid, cranialCenter: CGPoint
    let cranialRadius: CGFloat
    let eyeAngle: CGFloat
    
    init(face: CleanFaceData, drawnSize: CGSize, offsetPoint: CGPoint) {
        let makeCGPoint = { (p: AnchorPoint) -> CGPoint in
            CGPoint(x: p.x * drawnSize.width + offsetPoint.x,
                    y: p.y * drawnSize.height + offsetPoint.y);
        }
        
        let avg2 = { (_ a: CGFloat, _ b: CGFloat) in
            (a + b)/2
        }
        
        self.chin = makeCGPoint(face.chin)
        self.nose = makeCGPoint(face.nose)
        self.mouth = makeCGPoint(face.mouth)
        self.leftEyeTop = makeCGPoint(face.leftEyeTop)
        self.leftEyeBottom = makeCGPoint(face.leftEyeBottom)
        self.rightEyeTop = makeCGPoint(face.rightEyeTop)
        self.rightEyeBottom = makeCGPoint(face.rightEyeBottom)
        self.leftSide = makeCGPoint(face.leftSide)
        self.rightSide = makeCGPoint(face.rightSide)
        
        let leftEyeCenter = CGPoint(x: avg2(leftEyeTop.x, leftEyeBottom.x),
                                    y: avg2(leftEyeTop.y, leftEyeBottom.y))
        let rightEyeCenter = CGPoint(x: avg2(rightEyeTop.x, rightEyeBottom.x),
                                     y: avg2(rightEyeTop.y, rightEyeBottom.y))
        
        self.eyeMid = CGPoint(x: avg2(leftEyeCenter.x, rightEyeCenter.x),
                              y: avg2(leftEyeCenter.y, rightEyeCenter.y))
        
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
        self.eyeAngle = atan2(rightEyeCenter.y - leftEyeCenter.y, rightEyeCenter.x - leftEyeCenter.x)
        
        self.cranialRadius = (maxDist * 1.10 * (1.0 - yawIntensity)) + (((0.6 + (noseRatio * 0.4)) * lowerFaceHeight) * yawIntensity)
        self.cranialCenter = CGPoint(
            x: eyeMid.x + (latDX * cranialRadius * yawIntensity * 0.9),
            y: eyeMid.y - (cranialRadius * (0.3 + (noseRatio * 0.35))) + (pitchDelta * 0.35) + (latDY * cranialRadius * yawIntensity * 0.9)
        )
    }
    
    func getCraniumPath() -> Path {
        var path = Path()
        path.addArc(center: cranialCenter, radius: cranialRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        return path
    }
    
    func getCenterAxisPath() -> Path {
        let dist = hypot(eyeMid.x - chin.x, eyeMid.y - chin.y)
        let len = dist + (cranialRadius * 2.0)
        
        var centerLine = Path()
        centerLine.move(to: chin)
        centerLine.addLine(to: CGPoint(x: chin.x + ((mouth.x - chin.x) / dist) * len,
                                       y: chin.y + ((mouth.y - chin.y) / dist) * len))
        return centerLine
    }
    
    func getEyePath(top: Bool) -> Path {
        let left = top ? leftEyeTop : leftEyeBottom
        let right = top ? rightEyeTop : rightEyeBottom
        var path = Path()
        path.move(to: CGPoint(x: left.x - cos(eyeAngle) * 25.0, y: left.y - sin(eyeAngle) * 25.0))
        path.addLine(to: CGPoint(x: right.x + cos(eyeAngle) * 25.0, y: right.y + sin(eyeAngle) * 25.0))
        
        return path
    }
    
    func getChinPath() -> Path {
        var chinLine = Path()
        chinLine.move(to: CGPoint(x: chin.x - cos(eyeAngle) * 15.0, y: chin.y - sin(eyeAngle) * 15.0))
        chinLine.addLine(to: CGPoint(x: chin.x + cos(eyeAngle) * 15.0, y: chin.y + sin(eyeAngle) * 15.0))
        return chinLine
    }
}
