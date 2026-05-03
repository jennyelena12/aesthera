//
//  GuideStraightLine.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 03/05/26.
//

import Foundation
import SwiftUI
import PencilKit

struct GuideStraightLine: PencilKitConvertible {
    let startPoint: CGPoint, endPoint: CGPoint
    
    func asPKStroke(color: UIColor, width: CGFloat) -> PKStroke {
        let p1 = PKStrokePoint(location: startPoint, timeOffset: 0,
                               size: CGSize(width: width, height: width),
                               opacity: 1, force: 1, azimuth: 0, altitude: 0)
        let p2 = PKStrokePoint(location: endPoint, timeOffset: 0.1,
                               size: CGSize(width: width, height: width),
                               opacity: 1, force: 1, azimuth: 0, altitude: 0)
        
        let path = PKStrokePath(controlPoints: [p1, p2], creationDate: Date())
        
        return PKStroke(ink: PKInk(.pen, color: color), path: path)
    }
}
