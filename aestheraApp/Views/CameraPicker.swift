//
//  CameraPicker.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.


import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {

    let onCapture: (UIImage) -> Void

    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.allowsEditing = false          
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {

        private let parent: CameraPicker
        private var didFinish = false

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard !didFinish else { return }
            didFinish = true

            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            } else {
                parent.onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            guard !didFinish else { return }
            didFinish = true
            parent.onCancel()
        }
    }
}
