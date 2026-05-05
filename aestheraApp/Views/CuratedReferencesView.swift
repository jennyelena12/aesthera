//
//  CuratedReferencesView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI

// PRD: Main Page → Curated References
//   ✓ Scrollable
//   ✓ Segmented control: All / Anime / Realism / Semi-Realism / Manga
//   ✓ 3-column grid
//   ✓ Tap → kicks off detection via the shared AppRouter
//
// NAVIGATION:
// This view doesn't manage detection state directly anymore.
// It just calls `router.startScan(with:)`, which:
//   1. Stashes the chosen image on the router
//   2. Pushes Route.loading onto the stack
//   3. LoadingView runs the ML, then asks the router to REPLACE
//      itself with .result or .fail
// Because LoadingView is replaced (not buried), back from
// Result/Fail returns directly here.

struct CuratedReferencesView: View {

    @Environment(AppRouter.self) private var router

    // MARK: - Filter

    enum CategoryFilter: String, CaseIterable, Identifiable {
        case all          = "All"
        case anime        = "Anime"
        case realism      = "Realism"
        case semiRealism  = "Semi-Realism"
        case manga        = "Manga"

        var id: String { rawValue }
    }

    // MARK: - Data model

    struct Reference: Identifiable {
        let id = UUID()
        let title: String
        let category: CategoryFilter
        let assetName: String
        let placeholderSymbol: String

        func image() -> UIImage {
            if let img = UIImage(named: assetName) { return img }
            let config = UIImage.SymbolConfiguration(pointSize: 240, weight: .regular)
            return UIImage(systemName: placeholderSymbol, withConfiguration: config)
                ?? UIImage()
        }
    }

    private let references: [Reference] = [
        Reference(title: "Anime A",        category: .anime,       assetName: "ref_anime_01",   placeholderSymbol: "person.fill"),
        Reference(title: "Anime B",        category: .anime,       assetName: "ref_anime_02",   placeholderSymbol: "person.crop.circle.fill"),
        Reference(title: "Anime C",        category: .anime,       assetName: "ref_anime_03",   placeholderSymbol: "person.bust.fill"),
        Reference(title: "Realism A",      category: .realism,     assetName: "ref_realism_01", placeholderSymbol: "face.smiling.inverse"),
        Reference(title: "Realism B",      category: .realism,     assetName: "ref_realism_02", placeholderSymbol: "face.dashed"),
        Reference(title: "Semi-Realism A", category: .semiRealism, assetName: "ref_semi_01",    placeholderSymbol: "person.crop.square"),
        Reference(title: "Semi-Realism B", category: .semiRealism, assetName: "ref_semi_02",    placeholderSymbol: "person.crop.rectangle"),
        Reference(title: "Manga A",        category: .manga,       assetName: "ref_manga_01",   placeholderSymbol: "scribble"),
        Reference(title: "Manga B",        category: .manga,       assetName: "ref_manga_02",   placeholderSymbol: "scribble.variable"),
    ]

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
                    Image(systemName: ref.placeholderSymbol)
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
