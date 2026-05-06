//
//  ReferenceCard.swift
//  aestheraApp
//
//  Reusable card used in the Home grid (and anywhere else we want to show
//  a thumbnail with a title and a category tag).
//
//  Sizing rules — all enforced here, not at the call site:
//   • The image area is always a 1:1 square, regardless of the asset's
//     native aspect ratio. We .scaledToFill + .clipped to crop cleanly.
//   • The title is always one line. Long names shrink (minimumScaleFactor)
//     instead of wrapping, so the card never grows taller than its siblings.
//   • The badge always renders at the same height — even when the label is
//     empty we keep an invisible placeholder so the footer stays aligned.
//   • The whole card uses .frame(maxWidth: .infinity) so it fills its grid
//     column equally with neighbors.
//

import SwiftUI


struct ReferenceCard: View {

    // MARK: - Inputs

    let imageName: String
    let placeholderSymbol: String?
    let title: String
    let categoryLabel: String
    let categoryColor: Color


    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {

            imageArea
                .aspectRatio(1, contentMode: .fit)        // square — uniform across cards
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Radius.image, style: .continuous))

            Text(title)
                .font(.cardTitle)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            CategoryBadge(label: categoryLabel, tint: categoryColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(Color.cardSurface)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }


    // MARK: - Image area

    private var imageArea: some View {
        ZStack {
            Color(.secondarySystemBackground)

            if let img = UIImage(named: imageName) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else if let symbol = placeholderSymbol {
                Image(systemName: symbol)
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            }
        }
        .clipped()                                        // contain .scaledToFill overflow
    }
}


// MARK: - CategoryBadge

/// Small pill that sits under the card title. Always renders at the same
/// height — when the label is empty (e.g. the "All" filter), we still
/// reserve the slot with a transparent placeholder so footer rows align.
struct CategoryBadge: View {

    let label: String
    let tint: Color

    var body: some View {
        Text(displayLabel)
            .font(.badge)
            .foregroundStyle(label.isEmpty ? Color.clear : Color.textPrimary.opacity(0.75))
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: Radius.badge, style: .continuous)
                    .fill(label.isEmpty ? Color.clear : tint)
            )
    }

    /// Use a non-empty string when the real label is empty so the layout
    /// reserves the same vertical space across every card.
    private var displayLabel: String {
        label.isEmpty ? " " : label
    }
}


// MARK: - Preview

#Preview("Card grid") {
    let columns = [GridItem(.flexible(), spacing: 12),
                   GridItem(.flexible(), spacing: 12)]
    return ScrollView {
        LazyVGrid(columns: columns, spacing: 12) {
            ReferenceCard(
                imageName: "ref_anime_01",
                placeholderSymbol: "person.fill",
                title: "Yuji Itadori",
                categoryLabel: "Anime",
                categoryColor: .badgeAnimeBg
            )
            ReferenceCard(
                imageName: "ref_semi_01",
                placeholderSymbol: "person.crop.square",
                title: "Annabelle",
                categoryLabel: "Semi-Realist",
                categoryColor: .badgeSemiRealistBg
            )
            ReferenceCard(
                imageName: "ref_manga_01",
                placeholderSymbol: "scribble",
                title: "A Very Long Character Name",
                categoryLabel: "Manga",
                categoryColor: .badgeMangaBg
            )
            ReferenceCard(
                imageName: "ref_realism_01",
                placeholderSymbol: "face.smiling.inverse",
                title: "Elena",
                categoryLabel: "Realist",
                categoryColor: .badgeRealistBg
            )
        }
        .padding()
    }
    .background(Color.appBackground)
}
