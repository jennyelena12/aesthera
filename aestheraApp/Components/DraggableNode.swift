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
    
    @State private var dragStartPoint: AnchorPoint?
    @State private var isDragging: Bool = false;
    
    var body: some View {
        let screenX = (point.x * drawnWidth) + offsetX
        let screenY = (point.y * drawnHeight) + offsetY
        
        ZStack {
            Circle()
                .fill(color.opacity(0.5))
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                .shadow(radius: 2)
        }
        
        .frame(width: 44, height: 44) // biar good ux, seingatku apple ngasih touch sizenya harus brp gitu
        .contentShape(Circle())
        .position(x: screenX, y: screenY)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true;
                    if dragStartPoint == nil { dragStartPoint = point }
                    let normX = value.translation.width / drawnWidth
                    let normY = (value.translation.height - 40) / drawnHeight
                    
                    point.x = dragStartPoint!.x + normX
                    point.y = dragStartPoint!.y + normY
                }
                .onEnded { _ in
                    isDragging = false
                    dragStartPoint = nil
                }
        )
    }
    
}
