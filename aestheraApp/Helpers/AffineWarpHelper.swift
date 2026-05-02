//
//  AffineWarpHelper.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 02/05/26.
//

import Foundation
import CoreGraphics


struct AffineWarpHelper {
    
    static func warpAffine(source: CGImage, transform: AffineTransform, outputSize: CGSize) -> CGImage? {
        let W = Int(outputSize.width)
        let H = Int(outputSize.height)
        
        guard let ctx = CGContext(data: nil,
                                  width: W,
                                  height: H,
                                  bitsPerComponent: 8,
                                  bytesPerRow: W * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }
        
        ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        
        let inv = transform.inverted()
        let srcW = CGFloat(source.width)
        let srcH = CGFloat(source.height)
        
        ctx.translateBy(x: 0, y: CGFloat(H))
        ctx.scaleBy(x: 1, y: -1)
        
        let cgTransform = CGAffineTransform(
            a: inv.a, b: inv.c,
            c: inv.b, d: inv.d,
            tx: inv.tx, ty: inv.ty)
        
        ctx.concatenate(cgTransform)
        
        ctx.translateBy(x: 0, y: srcH)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(source, in: CGRect(x: 0, y: 0, width: srcW, height: srcH))
        
        return ctx.makeImage()
    }
}
