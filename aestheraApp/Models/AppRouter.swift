//
//  AppRouter.swift
//  aestheraApp
//
//  Centralized navigation coordinator for a single NavigationStack.
//

import SwiftUI

/// One `AppRouter` per `NavigationStack` in the app.
///
/// Why a router instead of plain NavigationLinks?
/// We need to *replace* views on the stack (not push) when the
/// transient LoadingView finishes detection. NavigationLink can only
/// push. With a typed `path: [Route]` we can mutate the stack directly:
///
///     var newPath = path
///     newPath.removeLast()      // pop loading
///     newPath.append(.result)   // push result
///     path = newPath            // single atomic update
///
/// That way, back from Result/Fail returns to the *source* screen,
/// not to a stuck Loading screen underneath.
///
/// Heavy payloads (UIImage, [CleanFaceData], error message) are stored
/// here on the router so the `Route` enum can stay simple/Hashable.
@Observable
class AppRouter {

    // MARK: - Routes

    /// Every screen reachable inside one NavigationStack.
    /// Cases are simple enough to be Hashable for free.
    enum Route: Hashable {
        case faceScanner          // teammate's monolithic ML demo (kept for now)
        case curatedReferences
        case tutorial
        case sheetGallery         // only used inside the "+" sheet stack
        case camera
        case loading
        case result
        case fail
        case canvas
    }

    // MARK: - Stack

    /// The navigation stack this router controls.
    /// Bind to `NavigationStack(path: $router.path)`.
    ///
    /// We use a typed `[Route]` (not NavigationPath) on purpose:
    ///   - Easier to inspect / debug — you can `print(router.path)`
    ///     and see exactly what's in there.
    ///   - `removeLast() + append()` reconciles cleanly when batched
    ///     through a single assignment (see `replaceTop` below).
    ///     With NavigationPath, those two mutations sometimes
    ///     reach SwiftUI as separate transactions, which can leave
    ///     the back-button's stack out of sync.
    var path: [Route] = []

    // MARK: - Scan-session payloads
    //
    // These are populated as the scan flow progresses, and read by
    // LoadingView / ResultView / FailView / DrawingCanvasView when
    // they appear. They live on the router (not on the Route enum)
    // because UIImage and [CleanFaceData] don't play nicely with
    // Hashable.

    var pendingImage: UIImage?
    var detectedFaces: [CleanFaceData] = []
    var failMessage: String = ""

    // MARK: - Navigation actions

    /// Start a scan: stash the image, then push loading screen.
    /// Called by source views (Curated, SheetGallery, Camera, etc).
    func startScan(with image: UIImage) {
        pendingImage = image
        detectedFaces = []
        failMessage = ""
        path.append(Route.loading)
    }

    /// Detection succeeded. Replace loading with result.
    /// Called from LoadingView when viewModel.detectionState == .success.
    func showResult(faces: [CleanFaceData]) {
        detectedFaces = faces
        replaceTop(with: .result)
    }

    /// Detection failed. Replace loading with fail.
    /// Called from LoadingView for .noFaceDetected / .error states.
    func showFail(message: String) {
        failMessage = message
        replaceTop(with: .fail)
    }

    /// Open the canvas on top of the stack (additional, not replacing).
    /// Called from ResultView's "Draw on Canvas" button.
    func openCanvas() {
        path.append(Route.canvas)
    }

    /// Pop just the top entry (one level up).
    /// Use this for "go back to source" from Fail/Result/Canvas —
    /// e.g. FailView's "Try another image" button.
    func popOne() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pop everything back to the root view (Home / SavedResults / etc.).
    /// Use sparingly — most "go back" actions should be `popOne()` so
    /// the user returns to the SOURCE of their flow, not the tab root.
    func popToRoot() {
        path = []
    }

    /// Push a non-scan route (e.g. tutorial, curated references).
    func push(_ route: Route) {
        path.append(route)
    }

    // MARK: - Helpers

    /// Pop the current top entry, then push a new one — atomically.
    /// This is the trick that makes back-from-Result/Fail return
    /// to the source screen instead of to LoadingView.
    ///
    /// We build the new path locally and assign it in ONE statement.
    /// That gives SwiftUI a single observation, so the NavigationStack
    /// reconciles cleanly and the system back button knows the right
    /// stack depth.
    private func replaceTop(with route: Route) {
        var newPath = path
        if !newPath.isEmpty { newPath.removeLast() }
        newPath.append(route)
        path = newPath
    }
}
