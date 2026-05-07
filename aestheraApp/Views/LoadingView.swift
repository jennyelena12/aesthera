//
//  LoadingView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI

// LoadingView is a transient screen pushed by AppRouter. It runs the
// ML detection on the router's pendingImage, then asks the router
// to REPLACE itself with .result or .fail. Because the router pops
// loading off the stack before pushing the next screen, back from
// Result/Fail returns to the source view (Curated, SheetGallery, …)
// and not to a stuck loading spinner.

struct LoadingView: View {

    let image: UIImage

    @Environment(AppRouter.self) private var router

    @State private var viewModel = FaceScannerViewModel()

    var body: some View {
        ZStack(){
            Image("background_asset")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.076)
                        .ignoresSafeArea() // Modern version of edgesIgnoringSafeArea
            
            VStack(spacing: 20) {
                Spacer()

                ProgressView()
                    .scaleEffect(1.5)

                Text("Detecting face proportions…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .navigationBarBackButtonHidden(true) // user can't go back mid-detection
            .navigationTitle("")
            .task {
                // Kick off detection. Async — the .onChange below reacts when finished.
                viewModel.processSelectedImage(image)
            }
            .onChange(of: viewModel.detectionState) { _, newState in
                switch newState {
                case .success(let faces):
                    // Router replaces .loading with .result on the stack.
                    router.showResult(faces: faces)
                case .noFaceDetected:
                    router.showFail(message: "We couldn't detect a face in your photo.")
                case .error(let msg):
                    router.showFail(message: msg)
                default:
                    break // .idle / .analyzing — keep showing the spinner
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoadingView(image: UIImage(systemName: "person.fill")!)
            .environment(AppRouter())
    }
}
