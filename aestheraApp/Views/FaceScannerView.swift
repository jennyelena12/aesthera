//
//  FaceScannerView.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation
import SwiftUI
import PhotosUI

struct FaceScannerView: View {
    @State private var viewModel = FaceScannerViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var resultFaces: [CleanFaceData] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        ZStack {
                            ForEach($resultFaces.indices, id: \.self) { idx in
                                AdjustableGuidelineOverlay(
                                    imageSize: image.size,
                                    face: $resultFaces[idx],
                                    lineWidth: 2.0)
                            }
                        }
                    )
            } else {
                VStack {
                    Image(systemName: "photo").font(.largeTitle)
                    Text("Select an Image")
                }
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            statusView
            
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Choose Image")
                    .font(.headline)
                    .padding()
            }
            .padding(.horizontal)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.processSelectedImage(uiImage)
                    }
                }
            }
            .onChange(of: viewModel.detectionState) { _, newState in
                if case .success(let faces) = newState {
                    resultFaces = faces
                }
                else {
                    resultFaces = []
                }
                
            }
        }
        .navigationTitle("Miawmiaw")
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch viewModel.detectionState {
        case .idle:
            Text("Ready to Analyze")
        case .analyzing:
            ProgressView("Loading...")
        case .success(let array):
            Text("\(array.count) Face(s) detected!")
        case .noFaceDetected:
            Text("No Face Detected :(")
        case .error(let error):
            Text("Error: \(error)").foregroundStyle(.red)
        }
    }
}
