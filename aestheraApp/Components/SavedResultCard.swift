//
//  SavedResultCell.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 07/05/26.
//

import Foundation
import SwiftUI

struct SavedResultCard: View {
    let scan: SavedScan
    let title: String
    let dateString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Group {
                        if let img = SavedScanStore.loadImage(for: scan) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)
                                )
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(dateString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)
        }
    }}
