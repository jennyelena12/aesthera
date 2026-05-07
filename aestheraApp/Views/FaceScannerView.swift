//
//  FaceScannerView.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 01/05/26.
//

//
//import Foundation
//import SwiftUI
//import PhotosUI
//import PencilKit
//
//extension Comparable {
//    func clamped(to limits: ClosedRange<Self>) -> Self {
//        return min(max(self, limits.lowerBound), limits.upperBound)
//    }
//}
//
//struct FaceScannerView: View {
//    @State private var viewModel = FaceScannerViewModel()
//    @State private var selectedItem: PhotosPickerItem? = nil
//    @State private var resultFaces: [CleanFaceData] = []
//    
//    @State private var guidelineCanvas = PKCanvasView()
//    @State private var drawingCanvas = PKCanvasView()
//    @State private var isDrawingMode = false
//    @State private var isEraser = false
//    @State private var currentZoomScale: CGFloat = 1.0
//    @State private var isZoomed: Bool = false
//    
////    @State private var showGuidelines = true
//    @State private var showDrawing = true
//    @State private var showBaseImage = true
//    @State private var showSaveAlert = false
//    
//    private let saveHelper = ImageSaveHelper()
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            
//            if let image = viewModel.selectedImage {
//                GeometryReader { geo in
//                    let scale = min(geo.size.width / image.size.width, geo.size.height / image.size.height)
//                    let drawnWidth = image.size.width * scale
//                    let drawnHeight = image.size.height * scale
//                    let offsetX = (geo.size.width - drawnWidth) / 2
//                    let offsetY = (geo.size.height - drawnHeight) / 2
//                    
//                    ZStack {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .opacity(showBaseImage ? 1.0 : 0.0)
//                        
//                        if !isDrawingMode {
//                            ForEach($resultFaces.indices, id: \.self) { index in
//                                AdjustableGuidelineOverlay(
//                                    imageSize: image.size,
//                                    face: $resultFaces[index],
//                                    lineWidth: 5.0
//                                )
//                            }
//                        }
//                        DrawingCanvasView(canvasView: $guidelineCanvas, isDrawingMode: .constant(false), isEraser: $isEraser)
//                            .allowsHitTesting(true)
//                        
//                        
//                    }
//                    .overlay(alignment: .bottomTrailing) {
//                        if !isDrawingMode && !resultFaces.isEmpty {
//                            Button("Convert to Canvas") {
//                                let drawing = GuidelineConvert.convertToDrawing(
//                                    faces: resultFaces,
//                                    drawnSize: CGSize(width: drawnWidth, height: drawnHeight),
//                                    offsetPoint: CGPoint(x: offsetX, y: offsetY),
//                                    width: 4.0
//                                )
//                                guidelineCanvas.drawing = drawing
//                                isDrawingMode = true
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .padding()
//                        }
//                    }
//                }
//                .frame(height: 500)
//                
//            } else {
//                VStack {
//                    Image(systemName: "photo").font(.largeTitle)
//                    Text("Select an Image")
//                }
//                .foregroundStyle(.secondary)
//            }
//            
//            Spacer()
//            
//            if isDrawingMode {
//                VStack {
//                    // Drawing Tools Stack (Pen, Eraser, Save, Trash)
//                    HStack(spacing: 40) {
//                        Button(action: { isEraser = false }) {
//                            toolButton(systemName: "pencil.tip", label: "Pen", isActive: !isEraser)
//                        }
//                        
//                        Button(action: { isEraser = true }) {
//                            toolButton(systemName: "eraser.fill", label: "Eraser", isActive: isEraser)
//                        }
//                        
//                        Button(action: { drawingCanvas.drawing = PKDrawing() }) {
//                            toolButton(systemName: "trash", label: "Clear", isActive: false, color: .red)
//                        }
//                        
//                        Button(action: saveDrawingOnly) {
//                            toolButton(systemName: "square.and.arrow.down", label: "Save", isActive: false, color: .green)
//                        }
//                    }
//                    
//                    Divider()
//                    
//                    // View Options Stack
//                    HStack(spacing: 20) {
//                        Toggle(isOn: $showBaseImage) {
//                            Label("Original Image", systemImage: "face.dashed")
//                                .font(.caption)
//                        }
//                        .toggleStyle(.button)
//                        
//                        Toggle(isOn: $showDrawing) {
//                            Label("My Drawing", systemImage: "paintbrush")
//                                .font(.caption)
//                        }
//                        .toggleStyle(.button)
//                    }
//                    .tint(.blue)
//                }
//                .padding()
//                .background(Color(.systemBackground))
//                .cornerRadius(15)
//                .shadow(radius: 5)
//            }
//            
//            statusView
//            
//            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
//                Text("Choose Image")
//                    .font(.headline)
//                    .padding()
//            }
//            .padding(.horizontal)
//            .alert("Saved!", isPresented: $showSaveAlert){
//                Button("OK", role: .cancel){}
//            } message:{
//                    Text("Your drawing has been saved!")
//                }
//            .onChange(of: selectedItem) { _, newItem in
//                Task {
//                    if let data = try? await newItem?.loadTransferable(type: Data.self),
//                       let uiImage = UIImage(data: data) {
//                        viewModel.processSelectedImage(uiImage)
//                    }
//                }
//            }
//            
//        }
//        .onChange(of: viewModel.detectionState) { _, newState in
//            if case .success(let faces) = newState {
//                resultFaces = faces
//                guidelineCanvas.drawing = PKDrawing()
//                drawingCanvas.drawing = PKDrawing()
//                guidelineCanvas.setZoomScale(1.0, animated: false)
//                isDrawingMode = false
//            } else {
//                resultFaces = []
//            }
//        }
//<<<<<<< HEAD
//        .navigationTitle("Aesthera")
//    }
//    
//    @ViewBuilder
//    private func toolButton(systemName: String, label: String, isActive: Bool, color: Color = .blue) -> some View {
//        VStack {
//            Image(systemName: systemName)
//                .font(.title2)
//            Text(label)
//                .font(.caption)
//        }
//        .foregroundColor(isActive ? .blue : (color == .blue ? .gray : color))
//=======
//        .navigationTitle("New Scan")
//        .navigationBarTitleDisplayMode(.inline)
//>>>>>>> origin
//    }
//    
//    @ViewBuilder
//    private var statusView: some View {
//        switch viewModel.detectionState {
//        case .idle:
//            Text("Ready to Analyze")
//        case .analyzing:
//            ProgressView("Loading...")
//        case .success(let array):
//            Text("\(array.count) Face(s) detected!")
//        case .noFaceDetected:
//            Text("No Face Detected :(")
//        case .error(let error):
//            Text("Error: \(error)").foregroundStyle(.red)
//        }
//    }
//    
//    private func saveDrawingOnly() {
//        let drawing = drawingCanvas.drawing
//        let bounds = drawingCanvas.bounds
//        
//        let format = UIGraphicsImageRendererFormat()
//        format.scale = UIScreen.main.scale
//        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
//        
//        let finalImage = renderer.image { ctx in
//            UIColor.white.setFill()
//            ctx.fill(bounds)
//            let drawingImage = drawing.image(from: bounds, scale: UIScreen.main.scale)
//            drawingImage.draw(in: bounds)
//        }
//        
//        if let jpgData = finalImage.jpegData(compressionQuality: 1.0),
//           let jpgImage = UIImage(data: jpgData) {
//            saveHelper.saveImage(jpgImage) {
//                showSaveAlert = true
//            }
//        }
//    }
//    
//    private func zoom(by factor: CGFloat) {
//        let newScale = (guidelineCanvas.zoomScale * factor)
//            .clamped(to: guidelineCanvas.minimumZoomScale...guidelineCanvas.maximumZoomScale)
//        guidelineCanvas.setZoomScale(newScale, animated: true)
//        currentZoomScale = newScale
//        isZoomed = newScale > 1.0
//    }
//    
//    private func resetZoom() {
//        guidelineCanvas.setZoomScale(1.0, animated: true)
//        currentZoomScale = 1.0
//        isZoomed = false
//    }
//    
//}
//

