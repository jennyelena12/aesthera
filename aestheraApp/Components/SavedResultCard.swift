//
//  SavedResultCard.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 07/05/26.
//
//  Visual style matches ReferenceCard on the Home grid — same card chrome,
//  same shadow, same radius, same Nunito date label. Two cards in different
//  grids should look like siblings, not strangers.
//

import Foundation
import SwiftUI


struct SavedResultCard: View {
    let scan: SavedScan
    let title: String
    let dateString: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {

            // Image area — same pattern as ReferenceCard:
            // square aspect, .scaledToFill + .clipped to crop cleanly.
            ZStack {
                Color(.secondarySystemBackground)

                if let img = SavedScanStore.loadImage(for: scan) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: Radius.image, style: .continuous))

            // Title slot — kept commented out since the 3-col grid is tight.
            // Re-enable here if you want titles back.
            //
            // Text(title)
            //     .font(.nunito(size: 12, weight: .semibold))
            //     .foregroundColor(Color.textPrimary)
            //     .lineLimit(1)
            //     .frame(maxWidth: .infinity, alignment: .leading)

            Text(dateString)
                .font(.nunito(size: 11, weight: .semibold))
                .foregroundColor(Color.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.s)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(Color.cardSurface)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
