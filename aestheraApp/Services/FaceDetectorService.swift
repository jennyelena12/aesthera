//
//  AnimeFaceDetectorService.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation
import CoreML
import Vision
import SwiftUI

class FaceDetectorService {
    static let instance = FaceDetectorService()
    
    private var yoloRequest: VNCoreMLRequest?
    private var landmarkRequest: VNCoreMLRequest?
    
    private init() {
        setupModels()
    }
    
    private func setupModels() {
        do {
            
            let yoloModel = try AnimeFaceYOLO(configuration: MLModelConfiguration()).model
            let landmarkModel = try AnimeFaceLandmarks(configuration: MLModelConfiguration()).model
            
            let yoloVisionModel = try VNCoreMLModel(for: yoloModel)
            let landmarkVisionModel = try VNCoreMLModel(for: landmarkModel)
            
            self.yoloRequest = VNCoreMLRequest(model: yoloVisionModel)
            self.landmarkRequest = VNCoreMLRequest(model: landmarkVisionModel)
            
            self.yoloRequest?.imageCropAndScaleOption = .scaleFill
            self.landmarkRequest?.imageCropAndScaleOption = .scaleFill
        } catch {
            print("Failed to load CoreML models: \(error)")
        }
    }
    
    func analyzeImage(_ image: UIImage) async throws -> [CleanFaceData] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Image"])
        }
        
        let yoloResults = try await runYOLO(on: cgImage)
        guard !yoloResults.isEmpty else {
            return [] }
        
        var validFaces: [CleanFaceData] = []
        
        for box in yoloResults {
            
            let squareBox = box
            
            let clampedBox = CGRect(
                x: max(0, squareBox.minX),
                y: max(0, squareBox.minY),
                width: min(1.0 - max(0, squareBox.minX), squareBox.width),
                height: min(1.0 - max(0, squareBox.minY), squareBox.height)
            )
            
            guard let cropped = cropImage(cgImage, toRect: clampedBox) else { continue }
            
            guard let faceData = try await runLandmarks(
                on: cropped,
                originalBoundingBox: clampedBox
            ) else { continue }
            
            validFaces.append(faceData)
        }
        return validFaces
    }
    
    private func runYOLO(on image: CGImage) async throws -> [CGRect] {
        guard let request = yoloRequest else { return [] }
        
//        request.imageCropAndScaleOption = .scaleFit
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])
        
        print("Test: \(String(describing: request.results))")
        
        guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
            print("Cast vauid,ediwujhndbeiljdbn")
            
            return []
        }
        return YOLODecoder.decode(features: results, treshold: 0.3, iouTreshold: 0.3)
    }
    
    private func runLandmarks(on croppedFace: CGImage, originalBoundingBox: CGRect) async throws -> CleanFaceData? {
        guard let request = landmarkRequest else { return nil }
        
        let handler = VNImageRequestHandler(cgImage: croppedFace, options: [:])
        try handler.perform([request])
        
        guard let results = request.results as? [VNCoreMLFeatureValueObservation],
              let multiArray = results.first?.featureValue.multiArrayValue else { return nil }
        
        print("Tensor SHape : \(multiArray)")
        
        guard let normalizedPoints = getNormalizedHeatMapCoordinate(multiArray), normalizedPoints.count == 28 else { return nil }
        
        
        
        let mappedPoints = normalizedPoints.map { point -> AnchorPoint in
            let absoluteX = originalBoundingBox.minX + (point.x * originalBoundingBox.width)
            let absoluteY = originalBoundingBox.minY + (point.y * originalBoundingBox.height)
            return AnchorPoint(x: absoluteX, y: absoluteY, confidence: 1.0)
        }
        
        
        return CleanFaceData(chin: mappedPoints[FaceFeatureIndex.chinIndex],
                             mouth: mappedPoints[FaceFeatureIndex.mouthIndex],
                             nose: mappedPoints[FaceFeatureIndex.noseIndex],
                             leftSide: mappedPoints[FaceFeatureIndex.leftSideIndex],
                             rightSide: mappedPoints[FaceFeatureIndex.rightSideIndex],
                             leftEyeTop: mappedPoints[FaceFeatureIndex.leftEyeTopIndex],
                             rightEyeTop: mappedPoints[FaceFeatureIndex.rightEyeTopIndex],
                             leftEyeBottom: mappedPoints[FaceFeatureIndex.leftEyeBottomIndex],
                             rightEyeBottom: mappedPoints[FaceFeatureIndex.rightEyeBottomIndex],
                             boundingBox: originalBoundingBox)
    }
    
    private func getNormalizedHeatMapCoordinate(_ multiArray: MLMultiArray) -> [CGPoint]? {
        guard multiArray.shape.count == 4 else { return nil }
        
        let K = multiArray.shape[1].intValue
        let height = multiArray.shape[2].intValue
        let width = multiArray.shape[3].intValue
        
        var points: [CGPoint] = []
        
        for k in 0..<K {
            var maxVal: Float = -.infinity
            var maxX = 0, maxY = 0
            
            for y in 0..<height {
                for x in 0..<width {
                    let idx: [NSNumber] = [0, NSNumber(value: k), NSNumber(value: y), NSNumber(value: x)]
                    let val = multiArray[idx].floatValue
                    if val > maxVal {
                        maxVal = val
                        maxX = x; maxY = y
                    }
                }
            }
            
            var refinedX = CGFloat(maxX)
            var refinedY = CGFloat(maxY)
            
            if maxX > 0 && maxX < width - 1 {
                let left  = multiArray[[0, NSNumber(value: k),
                                        NSNumber(value: maxY),
                                        NSNumber(value: maxX - 1)]].floatValue
                let right = multiArray[[0, NSNumber(value: k),
                                        NSNumber(value: maxY),
                                        NSNumber(value: maxX + 1)]].floatValue
                refinedX += CGFloat(right > left ? 0.25 : -0.25)
            }
            
            if maxY > 0 && maxY < height - 1 {
                let up   = multiArray[[0, NSNumber(value: k),
                                       NSNumber(value: maxY - 1),
                                       NSNumber(value: maxX)]].floatValue
                let down = multiArray[[0, NSNumber(value: k),
                                       NSNumber(value: maxY + 1),
                                       NSNumber(value: maxX)]].floatValue
                refinedY += CGFloat(down > up ? 0.25 : -0.25)
            }
            
            let nx = refinedX / CGFloat(width)
            let ny = refinedY / CGFloat(height)
            points.append(CGPoint(x: nx, y: ny))
        }
        
        return points
    }
    
    
    private func cropImage(_ image: CGImage, toRect rect: CGRect) -> CGImage? {
        let imgWidth = CGFloat(image.width)
        let imgHeight = CGFloat(image.height)
        
        let cropRect = CGRect(x: rect.minX * imgWidth,
                              y: rect.minY * imgHeight,
                              width: rect.width * imgWidth,
                              height: rect.height * imgHeight)
        
        return image.cropping(to: cropRect)
    }
}
