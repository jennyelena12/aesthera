//
//  aestheraAppApp.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 01/05/26.
//
import SwiftData
import SwiftUI

@main
struct aestheraAppApp: App {

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(onStart: { withAnimation(.easeInOut(duration: 0.4)) { showSplash = false } })
                    .onAppear {
                                showSplash = false
                            }
            }
            else {
                MainTabView()
            }
        }
        .modelContainer(for: SavedScan.self)
    }
}
