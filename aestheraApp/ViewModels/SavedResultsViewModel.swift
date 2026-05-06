//
//  SavedResultsViewModel.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 07/05/26.
//

import Foundation
import SwiftUI
import PhotosUI

@Observable
class SavedResultsViewModel {
    var selectedPhotoItem: PhotosPickerItem? = nil
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Created Today"
        } else if calendar.isDateInYesterday(date) {
            return "Created Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return "Created \(formatter.string(from: date))"
        }
    }
    
    func generateTitle(for index: Int, totalCount: Int) -> String {
        return "Untitled_\(totalCount - index)"
    }
    
    @MainActor
    func processSelectedPhoto(newItem: PhotosPickerItem?, router: AppRouter) async {
        guard let newItem = newItem else { return }
        
        if let data = try? await newItem.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            
            router.startScan(with: uiImage)
        }
    }
}
