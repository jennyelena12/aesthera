//
//  HomeView.swift
//  aestheraApp
//
//  Translated from Figma "Home Page" frame.
//  Layout breakdown (top → bottom):
//    1. Header row     — title + help "?" button
//    2. "Pick your own reference" section — two big CTA cards
//    3. "Pick from our examples" section — horizontal chip filter + 2-col grid
//
//  All colors / fonts / radii come from Theme.swift so this view stays
//  declarative. If Figma values change, edit Theme.swift, not this file.
//

import SwiftUI
import PhotosUI


struct HomeView: View {

    // MARK: - Routing & sheet state

    @Environment(AppRouter.self) private var router

    @State private var selectedFilter: HomeCategoryFilter = .all
    @State private var showPhotoPicker = false
    @State private var photoItem: PhotosPickerItem? = nil


    // MARK: - Filter
    // Local to this screen. `rawValue` matches the strings in
    // curated_references.json so filtering Just Works. `displayName`
    // is what shows up on the chip (matches the Figma copy exactly).

    enum HomeCategoryFilter: String, CaseIterable, Identifiable {
        case all          = "All"
        case anime        = "Anime"
        case manga        = "Manga"
        case semiRealist  = "Semi-Realism"   // matches JSON
        case realist      = "Realism"        // matches JSON

        var id: String { rawValue }

        /// Label shown on the chip — matches the Figma exactly.
        var displayName: String {
            switch self {
            case .all:         return "All"
            case .anime:       return "Anime"
            case .manga:       return "Manga"
            case .semiRealist: return "SemiRealist"
            case .realist:     return "Realist"
            }
        }

        /// Tint behind the small category badge under each card.
        var badgeColor: Color {
            switch self {
            case .all, .anime: return .badgeAnimeBg
            case .manga:       return .badgeMangaBg
            case .semiRealist: return .badgeSemiRealistBg
            case .realist:     return .badgeRealistBg
            }
        }

        /// Pretty form of the badge label (note: badge says "Semi-Realist",
        /// the chip says "SemiRealist" — that matches the Figma).
        var badgeLabel: String {
            switch self {
            case .all:         return ""
            case .anime:       return "Anime"
            case .manga:       return "Manga"
            case .semiRealist: return "Semi-Realist"
            case .realist:     return "Realist"
            }
        }

        /// Map a JSON category string back to one of these cases.
        static func from(jsonCategory: String) -> HomeCategoryFilter {
            HomeCategoryFilter(rawValue: jsonCategory) ?? .all
        }
    }


    // MARK: - Data
    // Decoded once from curated_references.json (same file used elsewhere).

    struct Reference: Identifiable, Decodable {
        let title: String
        let category: String
        let assetName: String
        let placeholderSymbol: String?

        var id: String { assetName }

        var image: UIImage {
            if let img = UIImage(named: assetName) { return img }
            let cfg = UIImage.SymbolConfiguration(pointSize: 240, weight: .regular)
            if let sym = placeholderSymbol,
               let img = UIImage(systemName: sym, withConfiguration: cfg) {
                return img
            }
            return UIImage()
        }
    }

    private let references: [Reference] = Self.loadReferences()

    private static func loadReferences() -> [Reference] {
        guard let url = Bundle.main.url(forResource: "curated_references", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Reference].self, from: data)
        else { return [] }
        return decoded
    }

    private var filteredReferences: [Reference] {
        guard selectedFilter != .all else { return references }
        return references.filter { $0.category == selectedFilter.rawValue }
    }


    // MARK: - Layout constants

    private let gridColumns = [
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m),
    ]


    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {

                    headerRow

                    pickYourOwnSection

                    pickFromExamplesSection
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, Spacing.s)
                // Leave room at the bottom for the floating tab bar.
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: photoItem) { _, newItem in
            handlePickedPhoto(newItem)
        }
    }


    // MARK: - Sections

    private var headerRow: some View {
        HStack(alignment: .center) {
            Text("What are we drawing today?")
                .font(.screenTitle)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: Spacing.m)

            Button {
                // Help → tutorial.
                router.push(.tutorial)
            } label: {
                Image(systemName: "questionmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.cardSurface, in: Circle())
                    .overlay(Circle().stroke(Color.cardBorder, lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Help")
        }
    }


    private var pickYourOwnSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Pick your own reference")
                .font(.sectionTitle)
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: Spacing.m) {
                CTACard(
                    title: "Open\nCamera",
                    iconName: "camera",
                    background: .brandNavy,
                    foreground: .textOnDark
                ) {
                    router.push(.camera)
                }

                CTACard(
                    title: "Upload from\nPhotos",
                    iconName: "photo",
                    background: .brandTeal,
                    foreground: .textOnDark
                ) {
                    showPhotoPicker = true
                }
            }
        }
    }


    private var pickFromExamplesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Pick from our examples")
                .font(.sectionTitle)
                .foregroundStyle(Color.textPrimary)

            // Horizontal chip filter row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    ForEach(HomeCategoryFilter.allCases) { filter in
                        FilterChip(
                            label: filter.displayName,
                            isActive: selectedFilter == filter
                        ) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            // 2-column grid of reference cards
            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: Spacing.m) {
                ForEach(filteredReferences) { ref in
                    let filter = HomeCategoryFilter.from(jsonCategory: ref.category)
                    Button {
                        router.startScan(with: ref.image)
                    } label: {
                        ReferenceCard(
                            imageName: ref.assetName,
                            placeholderSymbol: ref.placeholderSymbol,
                            title: ref.title,
                            categoryLabel: filter.badgeLabel,
                            categoryColor: filter.badgeColor
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }


    // MARK: - PhotosPicker handler

    private func handlePickedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    photoItem = nil
                    router.startScan(with: uiImage)
                }
            }
        }
    }
}


// MARK: - Subview: CTA card (Open Camera / Upload from Photos)

private struct CTACard: View {
    let title: String
    let iconName: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                background

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.ctaTitle)
                        .foregroundStyle(foreground)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Spacer()

                    HStack {
                        Spacer()
                        Image(systemName: iconName)
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(foreground.opacity(0.45))
                    }
                }
                .padding(Spacing.l)
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Subview: filter chip

private struct FilterChip: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.chip)
                .foregroundStyle(isActive ? Color.textOnDark : Color.textPrimary)
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isActive ? Color.chipActiveBg : Color.chipInactiveBg)
                )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
            .environment(AppRouter())
    }
}
