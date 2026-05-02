//
//  YoloDecoder.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 02/05/26.
//

import Foundation
import CoreML
import CoreGraphics
import Vision

struct YOLOBox {
    let rect: CGRect
    let confidence: Float
}

class YOLODecoder {
    
    // Dimensi Yg biasa dipake YoloV3
    static let anchors: [Int: [CGSize]] = [
        16: [CGSize(width: 116, height: 90),
             CGSize(width: 156, height: 198),
             CGSize(width: 373, height: 326)],
        32: [CGSize(width: 30, height: 61),
             CGSize(width: 16, height: 30),
             CGSize(width: 59, height: 119)],
        64: [CGSize(width: 10, height: 13),
             CGSize(width: 16, height: 30),
             CGSize(width: 33, height: 23)]
    ]
    
    static func decode(features: [VNCoreMLFeatureValueObservation], treshold: Float = 0.5, iouTreshold: Float = 0.3) -> [CGRect] {
        var allBoxes: [YOLOBox] = []
        
        for feature in features {
            guard let multiArray = feature.featureValue.multiArrayValue else { continue }
            let shape = multiArray.shape
            
            guard shape.count == 4, shape[1].intValue == 18 else { continue }
            
            let gridSize = shape[2].intValue // antara 16, 32, 64
            guard let scaleAnchors = anchors[gridSize] else { continue }
            
            let stride = 512.0 / CGFloat(gridSize)
            
            for cy in 0..<gridSize {
                for cx in 0..<gridSize {
                    for a in 0..<3 {
                        let chOffset = a * 6;
                        
                        let objIndex: [NSNumber] = [0,
                                                    NSNumber(value: chOffset + 4),
                                                    NSNumber(value: cy),
                                                    NSNumber(value: cx)]
                        let clsIndex: [NSNumber] = [0,
                                                    NSNumber(value: chOffset + 5),
                                                    NSNumber(value: cy),
                                                    NSNumber(value: cx)]
                        
                        let obj = sigmoid(multiArray[objIndex].floatValue)
                        let cls = sigmoid(multiArray[clsIndex].floatValue)
                        let confidence = obj * cls
                        
                        if confidence > treshold {
                            let numY = NSNumber(value: cy)
                            let numX = NSNumber(value: cx)
                            
                            let tx = multiArray[[0, NSNumber(value: chOffset + 0), numY, numX]].floatValue
                            let ty = multiArray[[0, NSNumber(value: chOffset + 1), numY, numX]].floatValue
                            let tw = multiArray[[0, NSNumber(value: chOffset + 2), numY, numX]].floatValue
                            let th = multiArray[[0, NSNumber(value: chOffset + 3), numY, numX]].floatValue
                            
                            let bx = (CGFloat(sigmoid(tx)) + CGFloat(cx)) * stride
                            let by = (CGFloat(sigmoid(ty)) + CGFloat(cy)) * stride
                            let bw = CGFloat(exp(tw)) * scaleAnchors[a].width
                            let bh = CGFloat(exp(th)) * scaleAnchors[a].height
                            
                            let rect = CGRect(x: bx - bw / 2.0,
                                              y: by - bh / 2.0,
                                              width: bw,
                                              height: bh)
                            let normalizedRect = CGRect(x: rect.minX / 512.0,
                                                        y: rect.minY / 512.0,
                                                        width: rect.width / 512.0,
                                                        height: rect.height / 512.0)
                            
                            allBoxes.append(YOLOBox(rect: normalizedRect, confidence: confidence))
                        }
                        
                    }
                }
            }
            
        }
        
        return nonMaxSuppression(boxes: allBoxes, iouTreshold: iouTreshold)
    }
    
    private static func sigmoid(_ x: Float) -> Float {
        return 1.0 / (1.0 + exp(-x));
    }
    
    private static func nonMaxSuppression(boxes: [YOLOBox], iouTreshold: Float) -> [CGRect] {
        let sortedBoxes = boxes.sorted { $0.confidence > $1.confidence }
        var selected: [CGRect] = []
        
        for box in sortedBoxes {
            var shouldSelect = true;
            for selectedBox in selected {
                let intersection = selectedBox.intersection(box.rect)
                if !intersection.isNull {
                    let intersectionArea = Float(intersection.width * intersection.height)
                    let area1 = Float(selectedBox.width * selectedBox.height)
                    let area2 = Float(box.rect.width * box.rect.height)
                    
                    let iou = intersectionArea / (area1 + area2 - intersectionArea)
                    
                    if(iou > iouTreshold) {
                        shouldSelect = false;
                        break;
                    }
                }
            }
            if shouldSelect { selected.append(box.rect) }
        }
        
        return selected
    }
}
