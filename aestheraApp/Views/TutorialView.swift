//
//  TutorialView.swift
//  aestheraApp
//

import SwiftUI

struct TutorialView: View {

    // TODO: Replace with actual tutorial content / design from Figma
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Tutorial")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Step-by-step guide will go here.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .navigationTitle("Tutorial")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
