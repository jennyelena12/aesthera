import SwiftUI
import PhotosUI
import AVFoundation

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var showHelp = false
    @State private var navigateToCanvas = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundDoodleView()
                
                VStack(spacing: 0) {
                    navigationBar
                    previewArea
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    Spacer()
                    
                    if capturedImage != nil {
                        Button {
                            navigateToCanvas = true
                        } label: {
                            Text("Draw with this image")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primary)
                                .foregroundStyle(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    bottomToolbar
                        .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .animation(.spring(duration: 0.3), value: capturedImage != nil)
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $capturedImage)
                    .ignoresSafeArea()
            }
            .alert("How to use", isPresented: $showHelp) {
                Button("Got it", role: .cancel) {}
            } message: {
                Text("Take a photo or pick one from your gallery. We'll generate anime face proportions for you to draw with.")
            }
            
            .navigationDestination(isPresented: $navigateToCanvas) {
                CanvasView(referenceImage: capturedImage)
            }
        }
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            // Back button - HIG: use chevron.left for back navigation
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("Pro-potion")
                        .fontWeight(.medium)
                }
                .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Help button - HIG: questionmark.circle for help
            Button {
                showHelp = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    // MARK: - Preview Area
    private var previewArea: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(.systemGray6))
            .overlay {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                } else {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 44))
                            .foregroundStyle(.tertiary)
                        Text("Take or choose a photo")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(3/4, contentMode: .fit)
    }
    
    // MARK: - Bottom Toolbar
    private var bottomToolbar: some View {
        HStack {
            Spacer()
            
            // Gallery picker - HIG: photo for Photos
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Image(systemName: "photo.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 52, height: 52)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        capturedImage = uiImage
                    }
                }
            }
            
            Spacer()
            
            // Camera shutter - HIG: large primary action button
            Button {
                showCamera = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.primary)
                        .frame(width: 72, height: 72)
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundStyle(.background)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Invisible spacer to balance the layout
            Color.clear
                .frame(width: 52, height: 52)
            
            Spacer()
        }
    }
}

// MARK: - Camera Picker (UIKit bridge)
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Background (swap with your actual doodle asset)
struct BackgroundDoodleView: View {
    var body: some View {
        // Replace with: Image("doodle_bg").resizable().ignoresSafeArea()
        Color(.systemBackground)
            .ignoresSafeArea()
    }
}

#Preview {
    UploadView()
}
