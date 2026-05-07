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
        GeometryReader { proxy in
            let width = proxy.size.width
            let safeInsets = proxy.safeAreaInsets

            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                Image("splashtopcorner")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, -safeInsets.top)
                    .padding(.leading, -safeInsets.leading)

                Image("splashmid")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.bottom, -safeInsets.bottom)
                    .padding(.trailing, -safeInsets.trailing)

                VStack(spacing: width * 0.08) {
                    Image("splashtitle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.8)

                    Image("splashsubtitle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.75)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 120)
                
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                onStart()
            }
            
        }
    }
}

#Preview {
    SplashView(onStart: {})
}
