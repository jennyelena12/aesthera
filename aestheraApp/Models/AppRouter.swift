//
//  AppRouter.swift
//  aestheraApp
//
//  Centralized navigation coordinator for a single NavigationStack.
//

import SwiftUI


@Observable
class AppRouter {

    // MARK: - Routes
    enum Route: Hashable {
        case faceScanner
        case curatedReferences
        case tutorial
        case sheetGallery
        case camera
        case loading
        case result
        case fail
        case canvas
    }

    // MARK: - Stack
    var path: [Route] = []

    // MARK: - Scan-session payloads
    var pendingImage: UIImage?
    var detectedFaces: [CleanFaceData] = []
    var failMessage: String = ""

    // MARK: - Navigation actions
    func startScan(with image: UIImage) {
        pendingImage = image
        detectedFaces = []
        failMessage = ""
        path.append(Route.loading)
    }

    func startScanReplacingTop(with image: UIImage) {
        pendingImage = image
        detectedFaces = []
        failMessage = ""
        var newPath = path
        if !newPath.isEmpty { newPath.removeLast() }
        newPath.append(.loading)
        path = newPath
    }


    func showResult(faces: [CleanFaceData]) {
        detectedFaces = faces
        replaceTop(with: .result)
    }

    func showFail(message: String) {
        failMessage = message
        replaceTop(with: .fail)
    }

    func openCanvas() {
        path.append(Route.canvas)
    }

    func popOne() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = []
    }

    func push(_ route: Route) {
        path.append(route)
    }

    // MARK: - Helpers

    private func replaceTop(with route: Route) {
        var newPath = path
        if !newPath.isEmpty { newPath.removeLast() }
        newPath.append(route)
        path = newPath
    }
}
