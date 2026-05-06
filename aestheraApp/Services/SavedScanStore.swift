//
//  SavedScanStore.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 06/05/26.
//

import Foundation
import SwiftData
import UIKit


struct SavedScanStore {

    let context: ModelContext

    // MARK: - Save

    @discardableResult
    func save(image: UIImage, faces: [CleanFaceData], source: String) -> SavedScan? {
        let id = UUID()
        let filename = "scan_\(id.uuidString).jpg"

        // 1. Encode + write JPEG bytes to Documents.
        guard let jpegData = image.jpegData(compressionQuality: 0.9) else { return nil }
        let fileURL = Self.documentsDirectory.appendingPathComponent(filename)
        do {
            try jpegData.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ SavedScanStore: failed to write JPEG: \(error)")
            return nil
        }

        // 2. Encode face data.
        guard let facesData = try? JSONEncoder().encode(faces) else {
            try? FileManager.default.removeItem(at: fileURL) // roll back the file
            return nil
        }

        // 3. Insert SwiftData row.
        let entry = SavedScan(
            id: id,
            createdAt: .now,
            imageFilename: filename,
            sourceLabel: source,
            facesData: facesData
        )
        context.insert(entry)
        do {
            try context.save()
            return entry
        } catch {
            print("⚠️ SavedScanStore: failed to save context: \(error)")
            try? FileManager.default.removeItem(at: fileURL)
            context.delete(entry)
            return nil
        }
    }

    // MARK: - Load
    static func loadImage(for scan: SavedScan) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent(scan.imageFilename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func loadFaces(for scan: SavedScan) -> [CleanFaceData] {
        (try? JSONDecoder().decode([CleanFaceData].self, from: scan.facesData)) ?? []
    }

    // MARK: - Delete

    func delete(_ scan: SavedScan) {
        let url = Self.documentsDirectory.appendingPathComponent(scan.imageFilename)
        try? FileManager.default.removeItem(at: url)
        context.delete(scan)
        try? context.save()
    }

    // MARK: - Helpers

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
