import SwiftUI
import SwiftData

struct SavedResultsView: View {

    // @Query reads from SwiftData and re-runs whenever the data changes.
    // Sort newest first.
    @Query(sort: [SortDescriptor(\SavedScan.createdAt, order: .reverse)])
    private var scans: [SavedScan]

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        Group {
            if scans.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(scans) { scan in
                            Button {
                                openSaved(scan)
                            } label: {
                                cell(for: scan)
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
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("My Works")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func cell(for scan: SavedScan) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))

            if let img = SavedScanStore.loadImage(for: scan) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
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

    // Reuses the existing .result route. Populates the router's payload
    // fields from the saved entry, then pushes Result.
    private func openSaved(_ scan: SavedScan) {
        guard let img = SavedScanStore.loadImage(for: scan) else { return }
        router.pendingImage = img
        router.detectedFaces = SavedScanStore.loadFaces(for: scan)
        router.failMessage = ""
        router.path.append(.result)
    }
}
