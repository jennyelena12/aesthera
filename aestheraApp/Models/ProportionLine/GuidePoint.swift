//
//  GuidePoint.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 04/05/26.
//

import Foundation
import PencilKit

struct GuidePoint: PencilKitConvertible {
    let location: CGPoint
    
    func asPKStroke(color: UIColor, width: CGFloat) -> PKStroke {
        let point = PKStrokePoint(location: location, timeOffset: 0,
                                  size: CGSize(width: width, height: width),
                                  opacity: 1, force: 1, azimuth: 0, altitude: 0)
        
        let path = PKStrokePath(controlPoints: [point], creationDate: Date())
        return PKStroke(ink: PKInk(.pen, color: .red), path: path)
    }
}
