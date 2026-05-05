//
//  aestheraAppApp.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 01/05/26.
//

import SwiftUI

@main
struct aestheraAppApp: App {

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                MainTabView()
            }
        }
    }
}
