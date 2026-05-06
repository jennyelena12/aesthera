//
//  RouteHosts.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI


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


private struct MissingDataPlaceholder: View {
    let text: String
    var body: some View {
        Text(text).foregroundStyle(.secondary)
    }
}
