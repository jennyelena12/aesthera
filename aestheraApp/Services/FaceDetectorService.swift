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
                    
                }
                
            }
        }
        return validFaces
    }
    
    private func runYOLO(on image: CGImage) async throws -> [CGRect] {
        guard let request = yoloRequest else { return [] }
        
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])
        
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return [] }
        return results.map { $0.boundingBox };
    }
    
    private func runLandmarks(on croppedFace: CGImage, originalBoundingBox: CGRect) async throws -> CleanFaceData? {
        guard let request = landmarkRequest else { return nil }
        
        let handler = VNImageRequestHandler(cgImage: croppedFace, options: [:])
        try handler.perform([request])
        
        guard let results = request.results as? [VNCoreMLFeatureValueObservation],
              let multiArray = results.first?.featureValue.multiArrayValue else { return nil }
        
        return nil
    }
    
    private func cropImage(_ image: CGImage, toRect rect: CGRect) -> CGImage? {
        let imgWidth = CGFloat(image.width)
        let imgHeight = CGFloat(image.height)
        
        let cropRect = CGRect(x: rect.minX * imgWidth,
                              y: (1 - rect.maxY) * imgHeight,
                              width: rect.width * imgWidth,
                              height: rect.height)
        
        return image.cropping(to: cropRect)
    }
}
