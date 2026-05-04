//
//  GuideCircle.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 03/05/26.
//

import Foundation
import CoreGraphics
import PencilKit

struct GuideCircle: PencilKitConvertible {
    let center: CGPoint, radius: CGFloat
    
    func asPKStroke(color: UIColor, width: CGFloat) -> PKStroke {
        var points: [PKStrokePoint] = []
        let res = 40;
        
        for i in 0...res {
            let angle = CGFloat(i) * (2.0 * .pi) / CGFloat(res)
            let loc = CGPoint(x: center.x + radius * cos(angle),
                              y: center.y + radius * sin(angle))
            
            let point = PKStrokePoint(location: loc, timeOffset: TimeInterval(i) * 0.01,
                                      size: CGSize(width: width, height: width),
                                      opacity: 1, force: 1, azimuth: 0, altitude: 0)
            points.append(point)
        }
        
        let path = PKStrokePath(controlPoints: points, creationDate: Date())
        return PKStroke(ink: PKInk(.pen, color: color), path: path)
    }
}
