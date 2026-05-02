//
//  AffineTransform.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 02/05/26.
//

import Foundation
import CoreGraphics
import Accelerate

struct AffineTransform {
    // tx ty untuk translasi, a, d untuk stretch, b, c untuk sheer, rotate
    var a: CGFloat, b: CGFloat, tx: CGFloat
    var c: CGFloat, d: CGFloat, ty: CGFloat
    
    func apply(to point: CGPoint) -> CGPoint {
        return CGPoint(x: a * point.x + b * point.y + tx,
                       y: c * point.x + d * point.y + ty)
    }
    
    func inverted() -> AffineTransform {
        let det = a * d - b * c
        guard abs(det) > 1e-10 else { fatalError("Singular matrix") }
        let invDet = 1.0 / det
        
        return AffineTransform(a: d * invDet,
                               b: -b * invDet,
                               tx: (b * ty - d * tx) * invDet,
                               c: -c * invDet,
                               d: a * invDet,
                               ty: (c * tx - a * ty) * invDet)
    }
    
    // dpt reference dari affine transformnya mmpose di python
    
    static func getAffineTransform(center: CGPoint, scale: CGSize, outputSize: CGSize) -> AffineTransform {
        let sourceW = scale.width
    
        let dstW = outputSize.width
        let dstH = outputSize.height
        
        let sourceDirection = CGPoint(x: 0, y: -sourceW * 0.5)
        let dstDirection = CGPoint(x: 0, y: -dstW * 0.5)
        
        let src0 = center
        let src1 = CGPoint(x: center.x + sourceDirection.x,
                           y: center.y + sourceDirection.y)
        let src2 = getThirdPoint(src0, src1)
        
        let dst0 = CGPoint(x: dstW * 0.5, y: dstH * 0.5)
        let dst1 = CGPoint(x: dstW * 0.5 + dstDirection.x, y: dstH * 0.5 + dstDirection.y)
        let dst2 = getThirdPoint(dst0, dst1)
        
        return getAffineFromTriangle(src: (src0, src1, src2), dst: (dst0, dst1, dst2))
        
    }
    
    static func getThirdPoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        let direction = CGPoint(x: b.x - a.x, y: b.y - a.y);
        
        return CGPoint(x: b.x - direction.y, y: b.y + direction.x)
    }
    
    static func getAffineFromTriangle(src: (CGPoint, CGPoint, CGPoint),
                               dst: (CGPoint, CGPoint, CGPoint)) -> AffineTransform {
        let s = [src.0, src.1, src.2]
        let ds = [dst.0, dst.1, dst.2]
            
        let A3: [CGFloat] = [
            s[0].x, s[0].y, 1,
            s[1].x, s[1].y, 1,
            s[2].x, s[2].y, 1
        ]
        
        let bX: [CGFloat] = [ds[0].x, ds[1].x, ds[2].x]
        let bY: [CGFloat] = [ds[0].y, ds[1].y, ds[2].y]
        
        let (a, b, tx) = solveMatrixLinear(A3, bX)
        let (c, d, ty) = solveMatrixLinear(A3, bY)
    
        return AffineTransform(a: a, b: b, tx: tx, c: c, d: d, ty: ty)
    }
    
    // rumus Ax = b, kita cari si X pake rumus cramer, A matrix 3x3, x dan b 3x1
    static private func solveMatrixLinear(_ A: [CGFloat], _ b: [CGFloat]) -> (CGFloat, CGFloat, CGFloat) {
        let a00 = A[0]; let a01 = A[1]; let a02 = A[2]
        let a10 = A[3]; let a11 = A[4]; let a12 = A[5]
        let a20 = A[6]; let a21 = A[7]; let a22 = A[8]
        
        let det = a00*(a11*a22 - a12*a21) - a01*(a10*a22 - a12*a20) + a02*(a10*a21 - a11*a20)

        let x = (b[0]*(a11*a22 - a12*a21) - a01*(b[1]*a22 - a12*b[2]) + a02*(b[1]*a21 - a11*b[2])) / det
        let y = (a00*(b[1]*a22 - a12*b[2]) - b[0]*(a10*a22 - a12*a20) + a02*(a10*b[2] - b[1]*a20)) / det
        let z = (a00*(a11*b[2] - b[1]*a21) - a01*(a10*b[2] - b[1]*a20) + b[0]*(a10*a21 - a11*a20)) / det
        return (x, y, z);
    }
}
