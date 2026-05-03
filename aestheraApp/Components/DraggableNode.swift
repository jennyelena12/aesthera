//
//  DraggableNode.swift
//  aestheraApp
//
//  Created by Xaviero Yamin Loganta on 03/05/26.
//

import Foundation
import SwiftUI

struct DraggableNode: View {
    @Binding var point: AnchorPoint
    let drawnWidth: CGFloat, drawnHeight: CGFloat
    let offsetX: CGFloat, offsetY: CGFloat
    let color: Color
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        let screenX = (point.x * drawnWidth) + offsetX + dragOffset.width
        let screenY = (point.y * drawnHeight) + offsetY + dragOffset.height
        
        Circle()
            .fill(color)
            .frame(width: 24, height: 24)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 2)
            .position(x: screenX, y: screenY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.dragOffset = value.translation
                    }
                    .onEnded { value in
                        let normX = value.translation.width / drawnWidth
                        let normY = value.translation.height / drawnHeight
                        
                        point.x = normX
                        point.y = normY
                        
                        self.dragOffset = .zero
                    }
            )
    }
    
}
