//
//  FaceScannerView.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

import Foundation
import SwiftUI
import PhotosUI
import PencilKit

struct FaceScannerView: View {
    @State private var viewModel = FaceScannerViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var resultFaces: [CleanFaceData] = []
    
    @State private var pkCanvasView = PKCanvasView()
    @State private var pkToolPicker = PKToolPicker()
    @State private var isDrawingMode = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if let image = viewModel.selectedImage {
                GeometryReader { geo in
                    let scale = min(geo.size.width / image.size.width, geo.size.height / image.size.height)
                    let drawnWidth = image.size.width * scale
                    let drawnHeight = image.size.height * scale
                    let offsetX = (geo.size.width - drawnWidth) / 2
                    let offsetY = (geo.size.height - drawnHeight) / 2
                    
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if !isDrawingMode {
                            ForEach($resultFaces.indices, id: \.self) { index in
                                AdjustableGuidelineOverlay(
                                    imageSize: image.size,
                                    face: $resultFaces[index],
                                    lineWidth: 5.0
                                )
                            }
                        }
                        MockPencilKitCanvas(canvasView: $pkCanvasView, toolPicker: $pkToolPicker)
                            .allowsHitTesting(isDrawingMode)
                        
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if !isDrawingMode && !resultFaces.isEmpty {
                            Button("Convert to Canvas") {
                                let drawing = GuidelineConvert.convertToDrawing(
                                    faces: resultFaces,
                                    drawnSize: CGSize(width: drawnWidth, height: drawnHeight),
                                    offsetPoint: CGPoint(x: offsetX, y: offsetY),
                                    width: 4.0
                                )
                                pkCanvasView.drawing.append(drawing)
                                isDrawingMode = true
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                    }
                }
                .frame(height: 500)
                
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
        .onChange(of: viewModel.detectionState) { _, newState in
            if case .success(let faces) = newState {
                resultFaces = faces
                pkCanvasView.drawing = PKDrawing()
                isDrawingMode = false
            } else {
                resultFaces = []
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

struct MockPencilKitCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {}
}
