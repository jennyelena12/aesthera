//
//  FaceMetrics+PencilKit.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 04/05/26.
//

import Foundation

extension FaceMetrics {
    func exportAsPencilKitShape() -> [PencilKitConvertible] {
        var shapes: [PencilKitConvertible] = []
        
        shapes.append(GuideCircle(center: cranialCenter, radius: cranialRadius))
        
        
        shapes.append(getCenterAxisShape())
        
        for x in [true, false] {
            shapes.append(getEyeLineShape(top: x))
        }
        shapes.append(getChinLineShape())
        shapes.append(getPointShape(leftEyeCenter))
        shapes.append(getPointShape(rightEyeCenter))
        shapes.append(getPointShape(mouth))
        shapes.append(getPointShape(nose))
        
        return shapes
    }
    
    func getCenterAxisShape() -> PencilKitConvertible {
        let dist = hypot(eyeMid.x - chin.x, eyeMid.y - chin.y)
        let len = dist + (cranialRadius * 2.0) + (eyeMid.y - chin.y)
        let axisEnd = CGPoint(x: chin.x + ((mouth.x - chin.x) / dist) * len,
                                       y: chin.y + ((eyeMid.y - chin.y) / dist) * len)
        return GuideStraightLine(startPoint: chin, endPoint: axisEnd)
    }
    
    func getEyeLineShape(top: Bool) -> PencilKitConvertible {
        let left = top ? leftEyeTop : leftEyeBottom
        let right = top ? rightEyeTop : rightEyeBottom
        let startPoint =  CGPoint(x: left.x - cos(eyeAngle) * 25.0, y: left.y - sin(eyeAngle) * 25.0)
        let endPoint = CGPoint(x: right.x + cos(eyeAngle) * 25.0, y: right.y + sin(eyeAngle) * 25.0)
        
        return GuideStraightLine(startPoint: startPoint, endPoint: endPoint)
    }
    
    func getChinLineShape() -> PencilKitConvertible {
        let startPoint = CGPoint(x: chin.x - cos(eyeAngle) * 15.0, y: chin.y - sin(eyeAngle) * 15.0)
        let endPoint = CGPoint(x: chin.x + cos(eyeAngle) * 15.0, y: chin.y + sin(eyeAngle) * 15.0)
        return GuideStraightLine(startPoint: startPoint, endPoint: endPoint)
    }
    
    func getPointShape(_ point: CGPoint) -> PencilKitConvertible {
        return GuidePoint(location: point)
    }
}
