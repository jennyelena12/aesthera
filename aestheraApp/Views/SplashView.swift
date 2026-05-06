//
//  SplashView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//

import SwiftUI

struct SplashView: View {
    var onStart: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)

                Text("PropPotion")
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
