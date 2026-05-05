//
//  FailView.swift
//  aestheraApp
//

import SwiftUI

struct FailView: View {

    @Environment(AppRouter.self) private var router

    // TODO: Add example images (what works / what doesn't) — Stage 2
    var errorMessage: String = "We couldn't detect a face in your photo."

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // TODO: Replace with "Icon Hantu" asset from Figma
            Text("👻")
                .font(.system(size: 72))

            Text("Oops!")
                .font(.title2.weight(.semibold))

            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            // Pop ONE level — back to the source view (Curated, Sheet, etc.).
            // Because the router already replaced .loading with .fail
            // (rather than pushing fail on top of loading), the source
            // view is the next entry below us in the stack.
            //
            // Using popToRoot() here would clear the WHOLE path —
            // including the .curatedReferences entry — and dump the
            // user on Home. popOne() is what we want.
            Button {
                router.popOne()
            } label: {
                Text("Try another image")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationTitle("No Face Detected")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FailView()
            .environment(AppRouter())
    }
}
