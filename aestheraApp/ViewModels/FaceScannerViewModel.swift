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
        self.selectedImage = compressImageRes(image)
//        print("New Size: \(selectedImage?.size.width) ,  \(selectedImage?.size.height)")
        self.detectionState = .analyzing
        
        guard let img = self.selectedImage else {return}
        Task {
            do {
                let results = try await FaceDetectorService.instance.analyzeImage(img)
                
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
    
    private func compressImageRes(_ img: UIImage) -> UIImage {
        let size = img.size
        let targetDim: CGFloat = 1024.0;
        
        let currDim = max(size.width, size.height)
        if(targetDim > currDim) {return img;}
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0;
        let scale = targetDim / currDim;
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let render = UIGraphicsImageRenderer(size: newSize, format: format)
        
        return render.image { _ in
            img.draw(in: CGRect(origin: .zero, size: newSize));
        }
        
    }
    
    func reset() {
        self.selectedImage = nil
        self.detectionState = .idle
    }
}
