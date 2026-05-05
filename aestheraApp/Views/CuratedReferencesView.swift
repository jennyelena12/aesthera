//
//  CuratedReferencesView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI


struct CuratedReferencesView: View {

    @Environment(AppRouter.self) private var router

    // MARK: - Filter

    /// Used for both the segmented control AND the per-reference
    /// `category` field decoded from JSON. `.all` is filter-only —
    /// it should never appear in `curated_references.json`.
    /// Conformance to `Decodable` lets each entry's `"category"` string
    /// in the JSON file map directly onto a case via its raw value.
    enum CategoryFilter: String, CaseIterable, Identifiable, Decodable {
        case all          = "All"
        case anime        = "Anime"
        case realism      = "Realism"
        case semiRealism  = "Semi-Realism"
        case manga        = "Manga"

        var id: String { rawValue }
    }

    // MARK: - Data model

    /// Decoded directly from `curated_references.json` at view init.
    /// `placeholderSymbol` is optional — JSON entries can omit it once
    /// the asset catalog has the real image. The view only falls back
    /// to an SF Symbol if both the asset and the placeholder are missing.
    struct Reference: Identifiable, Decodable {
        let title: String
        let category: CategoryFilter
        let assetName: String
        let placeholderSymbol: String?

        // Use the asset name as a stable identity. Unique per entry
        // and survives JSON reload, unlike a runtime-generated UUID.
        var id: String { assetName }

        func image() -> UIImage {
            if let img = UIImage(named: assetName) { return img }
            let config = UIImage.SymbolConfiguration(pointSize: 240, weight: .regular)
            if let symbol = placeholderSymbol,
               let img = UIImage(systemName: symbol, withConfiguration: config) {
                return img
            }
            return UIImage()
        }
    }

    /// Loaded once when the view is created. Synchronous because the
    /// JSON sits in the app bundle (no network) and the list is small.
    /// If decoding fails (file missing or malformed), we fall back to
    /// an empty array so the view still renders cleanly.
    private let references: [Reference] = Self.loadReferences()

    private static func loadReferences() -> [Reference] {
        guard let url = Bundle.main.url(forResource: "curated_references", withExtension: "json") else {
            print("⚠️ curated_references.json not found in bundle. Did you add it to the target?")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Reference].self, from: data)
        } catch {
            print("⚠️ Failed to decode curated_references.json: \(error)")
            return []
        }
    }

    // MARK: - State

    @State private var selectedFilter: CategoryFilter = .all

    private var filtered: [Reference] {
        guard selectedFilter != .all else { return references }
        return references.filter { $0.category == selectedFilter }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {

            // PRD: Segmented control
            Picker("Category", selection: $selectedFilter) {
                ForEach(CategoryFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            // PRD: Scrollable 3-column grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered) { ref in
                        Button {
                            // Hand off to the router. Router pushes .loading,
                            // LoadingView runs ML, then router swaps in .result or .fail.
                            router.startScan(with: ref.image())
                        } label: {
                            referenceCard(ref)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }

            if !anyAssetExists {
                Text("Drop reference images into Assets.xcassets named \"ref_anime_01\", \"ref_realism_01\", etc. to replace these placeholders.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }
        }
        .navigationTitle("Curated References")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Card

    @ViewBuilder
    private func referenceCard(_ ref: Reference) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 150, height: 150)

            if let img = UIImage(named: ref.assetName) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                VStack(spacing: 6) {
                    Image(systemName: ref.placeholderSymbol ?? "questionmark.square.dashed")
                        .font(.system(size: 30))
                        .foregroundStyle(.secondary)
                    Text(ref.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }

    private var anyAssetExists: Bool {
        references.contains { UIImage(named: $0.assetName) != nil }
    }
}

#Preview {
    NavigationStack {
        CuratedReferencesView()
            .environment(AppRouter())
    }
}
