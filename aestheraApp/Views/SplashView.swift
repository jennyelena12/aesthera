//
//  SplashView.swift
//  aestheraApp
//

import SwiftUI

struct SplashView: View {
    var onStart: () -> Void

    // TODO: Replace with final brand assets from Figma
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // TODO: Replace with app logo from Figma
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)

                Text("aesthera")
                    .font(.largeTitle.weight(.semibold))
                    .tracking(4)
                
                Button("Start") {
                    onStart()
                }
            }
        }
    }
}

#Preview {
    SplashView(onStart: {})
}
