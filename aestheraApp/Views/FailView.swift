//
//  FailView.swift
//  aestheraApp
//
//  Created by Jesslyn Trixie Edvilie on 04/05/26.
//
//  Layout matches the Figma "A - Failed" frame:
//
//   ┌──────────────────────────────────┐
//   │ !                              ? │  ← decorative marks (assets)
//   │                                  │
//   │ Uh! Oh!                          │  ← red headline
//   │ <bold error message>             │  ← black, bold
//   │ <gray helper text>               │  ← gray, regular
//   │ [ Retry ]                        │  ← red pill button (not full width)
//   │                                  │
//   │           failghost              │  ← bottom illustration
//   └──────────────────────────────────┘
//

import SwiftUI


struct FailView: View {

    @Environment(AppRouter.self) private var router

    var errorMessage: String = "Seems like we failed to identify the face feature!"


    var body: some View {
        ZStack(alignment: .topLeading) {

            HStack(alignment: .top) {
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.s)


           
            VStack(alignment: .leading, spacing: Spacing.l) {
                Spacer().frame(height: 130)

                Text("Uh! Oh!")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.black)

                Text(errorMessage)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Please follow the guide & requirements carefully and try again!")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

    
                Button {
                    router.popOne()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.body.weight(.semibold))
                        Text("Retry")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.brandNavy)
                    )
                }
                .frame(maxWidth: 220)         // ← partial width, not full

                Spacer()

                // Ghost at the bottom, centered
                Image("failghost")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, Spacing.l)
            }
            .padding(.horizontal, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    NavigationStack {
        FailView()
            .environment(AppRouter())
    }
}
