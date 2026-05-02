//
//  FaceScannerViewModel.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation
import SwiftUI

@Observable
class FaceScannerViewModel {
    var selectedImage: UIImage? = nil;
    var detectionState: FaceDetectionState = .idle
    
    func processSelectedImage(_ image: UIImage) {
        self.selectedImage = image
        self.detectionState = .analyzing
        
        Task {
            do {
                let results = try await FaceDetectorService.instance.analyzeImage(image)
                
                if results.isEmpty {
                    self.detectionState = .noFaceDetected
                }
                else {
                    self.detectionState = .success(results)
                }
            } catch {
                self.detectionState = .error(error.localizedDescription)
            }
        }
    }
    
    func reset() {
        self.selectedImage = nil
        self.detectionState = .idle
    }
}
