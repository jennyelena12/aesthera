//
//  OnboardingView.swift
//  aestheraApp
//
//  Created by Johanna Angel on 05/05/26.
//

import SwiftUI

struct OnboardingPage{
    let image: String
    let tutimage: String
    let title: String
    let subtitle: String
    let buttonText: String
}

let pages = [
    OnboardingPage(
        image: "bg1",
        tutimage: "tut1",
        title: "Pick Your Potion!",
        subtitle: "Upload a portrait or snap a photo to begin your magic.",
        buttonText: "skip"
    ),
    OnboardingPage(
        image: "bg2",
        tutimage: "tut2",
        title: "Brew The Proportion!",
        subtitle: "We'll generate guiding lines to help you get the proportions just right",
        buttonText: "skip"
    ),
    OnboardingPage(
        image: "bg3",
        tutimage: "tut3",
        title: "Craft Your Masterpiece!",
        subtitle: "Draw on our canvas or doownload your guide to create anywhere you like!",
        buttonText: "Ok, i'm ready."
    )
]

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            // Background Image
            Image(page.image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Overlay (biar text kebaca)
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 22) {
                    Image(page.tutimage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 210)
                        .clipShape(Capsule())
                    Text(page.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(page.subtitle)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                    
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        ContentView()
                    } label: {
                        Text(page.buttonText)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)
                }
            }.padding(.bottom, 60)
        }
    }
    
}

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            TabView {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
    }
}


#Preview {
    OnboardingView()
}
