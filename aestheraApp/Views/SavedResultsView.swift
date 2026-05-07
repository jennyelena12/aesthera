import SwiftUI
import SwiftData
import PhotosUI

struct SavedResultsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    
    @State private var viewModel = SavedResultsViewModel()
    
    @Query(sort: [SortDescriptor(\SavedScan.createdAt, order: .reverse)])
    private var scans: [SavedScan]
    
    @State private var showSourceDialog = false
    @State private var showPhotoPicker = false
    
    var onBackToDraw: (() -> Void)? = nil
    
    private let columns = [
        GridItem(.flexible(maximum: 160), spacing: 12),
        GridItem(.flexible(maximum: 160), spacing: 12),
        GridItem(.flexible(maximum: 160), spacing: 12)
    ]
    
    var body: some View {
        Group {
            if scans.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Array(scans.enumerated()), id: \.element.id) { index, scan in
                            Button {
                                openSaved(scan)
                            } label: {
                                SavedResultCard(
                                    scan: scan,
                                    title: viewModel.generateTitle(for: index, totalCount: scans.count),
                                    dateString: viewModel.formatDate(scan.createdAt)
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    let store = SavedScanStore(context: modelContext)
                                    store.delete(scan)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CircleIconButton(systemName: "chevron.left") {
                    if router.path.isEmpty {
                        onBackToDraw?()
                    } else {
                        router.popOne()
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Your Past Works")
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Upload from Photos", systemImage: "photo.on.rectangle")
                    }

                    Button {
                        router.push(.camera)
                    } label: {
                        Label("Open Camera", systemImage: "camera")
                    }
                } label: {
                    // Menu owns the tap, so use the chrome view (no Button wrapping)
                    CircleIconChrome(systemName: "plus", style: .primary, iconSize: 18)
                }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.selectedPhotoItem, matching: .images)
        .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
            Task {
                await viewModel.processSelectedPhoto(newItem: newItem, router: router)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No saved scans yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap Save on a result to add it here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
    
    private func openSaved(_ scan: SavedScan) {
        guard let img = SavedScanStore.loadImage(for: scan) else { return }
        router.pendingImage = img
        router.detectedFaces = SavedScanStore.loadFaces(for: scan)
        router.failMessage = ""
        router.path.append(.result)
    }
}
