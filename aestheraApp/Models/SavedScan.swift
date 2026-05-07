//
//  SavedScan.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 06/05/26.
//

import Foundation
import SwiftData


@Model
final class SavedScan {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var imageFilename: String   // e.g. "scan_1715000000.jpg" — joined with Documents dir at read time
    var sourceLabel: String     // "camera", "library", "curated", etc. (for filtering later if you want)
    var facesData: Data         // JSON-encoded [CleanFaceData]

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        imageFilename: String,
        sourceLabel: String,
        facesData: Data
    ) {
        self.id = id
        self.createdAt = createdAt
        self.imageFilename = imageFilename
        self.sourceLabel = sourceLabel
        self.facesData = facesData
    }
}
