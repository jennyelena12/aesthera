//
//  ImageSaveHelper.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 04/05/26.
//

import UIKit
class ImageSaveHelper: NSObject {
    var onComplete: (() -> Void)?

    func saveImage(_ image: UIImage, completion: @escaping () -> Void) {
        self.onComplete = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            onComplete?()
        } else {
            print("Save failed: \(error?.localizedDescription ?? "unknown error")")
        }
    }
}
