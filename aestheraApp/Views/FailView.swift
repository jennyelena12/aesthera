//
//  FailView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI

struct FailView: View {

    @Environment(AppRouter.self) private var router

    var errorMessage: String = "We couldn't detect a face in your photo."

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

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
