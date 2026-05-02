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
        
        if yoloResults.isEmpty { return [] }
        
        var validFaces: [CleanFaceData] = []
        
        for boundingBox in yoloResults {
            if let cropepdFaceImage = cropImage(cgImage, toRect: boundingBox) {
                if let faceData = try await runLandmarks(on: cropepdFaceImage, originalBoundingBox: boundingBox) {
                    validFaces.append(faceData)
                }
                
            }
        }
        return validFaces
    }
    
    private func runYOLO(on image: CGImage) async throws -> [CGRect] {
        guard let request = yoloRequest else { return [] }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])
        
        print("Test: \(String(describing: request.results))")
        
        guard let results = request.results as? [VNCoreMLFeatureValueObservation] else {
            print("Cast vauid,ediwujhndbeiljdbn")
            
            return []
        }
        return YOLODecoder.decode(features: results, treshold: 0.5, iouTreshold: 0.1)
    }
    
    private func runLandmarks(on croppedFace: CGImage, originalBoundingBox: CGRect) async throws -> CleanFaceData? {
        guard let request = landmarkRequest else { return nil }
        
        let handler = VNImageRequestHandler(cgImage: croppedFace, options: [:])
        try handler.perform([request])
        
        guard let results = request.results as? [VNCoreMLFeatureValueObservation],
              let multiArray = results.first?.featureValue.multiArrayValue else { return nil }
        
        var rawPoints: [CGPoint] = []
        
        print("Tensor SHape : \(multiArray)")
        
        // if else dibawah untuk handle kemungkinan return dari neural networknya (soalnya ga pasti yang mana satu, jd prevent satu satu)
        // case untuk array normal x,y x,y ...
        if multiArray.shape.count == 2 || (multiArray.shape.count == 1 && multiArray.count >= 56) {
            for i in stride(from: 0, to: 56, by: 2) {
                let x = CGFloat(truncating: multiArray[i])
                let y = CGFloat(truncating: multiArray[i+1])
                rawPoints.append(CGPoint(x: x, y: y))
            }
        }
        // case untuk heatmap atau bentuk 1,28, H,W
        else if multiArray.shape.count == 4 {

            let keypointsCount = multiArray.shape[1].intValue
            let height = multiArray.shape[2].intValue
            let width = multiArray.shape[3].intValue
            
            for k in 0..<keypointsCount {
                let (nX, nY) = getNormalizedHeatMapCoordinate(multiArray, height: height, width: width, k: k)
                rawPoints.append(CGPoint(x: nX, y: nY))
            }
        }
        else {
            print("Unrecognized Shape Error.")
            return nil
        }
        
        guard rawPoints.count == 28 else { return nil }
        
        let mappedPoints = rawPoints.map { point -> AnchorPoint in
            let absoluteX = originalBoundingBox.minX + (point.x * originalBoundingBox.width)
            let absoluteY = originalBoundingBox.minY + (point.y * originalBoundingBox.height)
            return AnchorPoint(x: absoluteX, y: absoluteY, confidence: 1.0)
        }
        
        return CleanFaceData(chin: mappedPoints[0],
                             mouth: mappedPoints[1],
                             nose: mappedPoints[2],
                             leftSide: mappedPoints[3],
                             rightSide: mappedPoints[4],
                             leftEyeTop: mappedPoints[5],
                             rightEyeTop: mappedPoints[6],
                             leftEyeBottom: mappedPoints[7],
                             rightEyeBottom: mappedPoints[8],
                             boundingBox: originalBoundingBox)
    }

    private func getNormalizedHeatMapCoordinate(_ multiArray: MLMultiArray, height: Int, width: Int, k: Int) -> (CGFloat, CGFloat){
        var maxVal: Float = -1.0
        var maxIndex = (x: 0, y: 0)
        
        for y in 0..<height {
            for x in 0..<width {
                let index = [0, NSNumber(value: k), NSNumber(value: y), NSNumber(value: x)];
                let val = multiArray[index].floatValue
                if val > maxVal {
                    maxVal = val
                    maxIndex = (x,y)
                }
            }
        }
        
        let nX = CGFloat(maxIndex.x) / CGFloat(width)
        let nY = CGFloat(maxIndex.y) / CGFloat(height)
        return (nX, nY)
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
