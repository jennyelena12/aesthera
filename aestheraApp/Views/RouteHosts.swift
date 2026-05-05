//
//  RouteHosts.swift
//  aestheraApp
//
//  Shared destination-view wrappers used by every NavigationStack.
//

import SwiftUI

// These tiny wrappers pull session data off the AppRouter and pass it
// into the existing screens via constructor parameters. The screens
// themselves stay router-unaware (they take plain UIImage / [CleanFaceData]
// arguments), which keeps them previewable and easy to test.
//
// Both MainTabView's tab stacks AND HomeView's "+" sheet stack route
// .loading / .result / .fail / .canvas through these wrappers — they
// used to be duplicated in each file, which was unnecessary.

struct LoadingViewHost: View {
    @Environment(AppRouter.self) private var router
    var body: some View {
        if let image = router.pendingImage {
            LoadingView(image: image)
        } else {
            MissingDataPlaceholder(text: "Missing image")
        }
    }
}

struct ResultViewHost: View {
    @Environment(AppRouter.self) private var router
    var body: some View {
        if let image = router.pendingImage {
            ResultView(image: image, faces: router.detectedFaces)
        } else {
            MissingDataPlaceholder(text: "Missing scan data")
        }
    }
}

struct FailViewHost: View {
    @Environment(AppRouter.self) private var router
    var body: some View {
        FailView(errorMessage: router.failMessage)
    }
}

struct DrawingCanvasViewHost: View {
    @Environment(AppRouter.self) private var router
    var body: some View {
        if let image = router.pendingImage {
            DrawingCanvasView(
                originalImage: image,
                faceObservations: router.detectedFaces
            )
        } else {
            MissingDataPlaceholder(text: "Missing scan data")
        }
    }
}

// Defensive placeholder — should never appear in normal flow, since
// startScan() always seeds pendingImage before pushing .loading.
private struct MissingDataPlaceholder: View {
    let text: String
    var body: some View {
        Text(text).foregroundStyle(.secondary)
    }
}
