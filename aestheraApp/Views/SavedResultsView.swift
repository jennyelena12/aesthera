//
//  SavedResultsView.swift
//  aestheraApp
//

import SwiftUI

struct SavedResultsView: View {

    // TODO: Hook up to a persistence layer (e.g. SwiftData / UserDefaults)
    // TODO: Replace placeholder layout with Figma design
    var body: some View {
        Group {
            // Swap this out once you have real saved data
            emptyState
        }
        .navigationTitle("Saved Results")
        .navigationBarTitleDisplayMode(.large)
    }

    // --- Empty state placeholder ---
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No saved results yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("After a scan, save your drawing\nand it will appear here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        SavedResultsView()
    }
}
