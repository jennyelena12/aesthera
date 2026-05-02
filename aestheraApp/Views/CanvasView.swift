//
//  CanvasView.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//

import SwiftUI

struct CanvasView: View {

    let referenceImage: UIImage?
    @State private var vm = CanvasViewModel()
    @State private var showToolbar = false
    @State private var showLayers = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {

            // White canvas background
            Color.white.ignoresSafeArea()

            // Reference image (faded underneath)
            if let image = referenceImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.3)
                    .ignoresSafeArea()
            }

            // All layers stacked on top of each other
            ZStack {
                ForEach(vm.layers) { layer in
                    if layer.isVisible {
                        DrawingCanvasLayer(
                            layer: layer,
                            currentStroke: layer.id == vm.activeLayer.id ? vm.currentStroke : nil
                        )
                    }
                }
            }
            .gesture(drawingGesture)

            // Top buttons
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .padding(12)
                            .background(.thinMaterial, in: Circle())
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        Button { showLayers.toggle() } label: {
                            Image(systemName: "square.3.layers.3d")
                                .padding(12)
                                .background(.thinMaterial, in: Circle())
                        }
                        Button { showToolbar.toggle() } label: {
                            Image(systemName: "pencil.tip.crop.circle")
                                .padding(12)
                                .background(.thinMaterial, in: Circle())
                        }
                    }
                }
                .padding()
                Spacer()
            }

            // Toolbar panel
            if showToolbar {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ToolbarComponent(vm: vm)
                            .frame(width: 220)
                            .padding()
                    }
                }
                .transition(.move(edge: .trailing))
            }

            // Layer panel
            if showLayers {
                VStack {
                    Spacer()
                    HStack {
                        LayerPanelComponent(vm: vm)
                            .frame(width: 200)
                            .padding()
                        Spacer()
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(duration: 0.3), value: showToolbar)
        .animation(.spring(duration: 0.3), value: showLayers)
    }

    // MARK: - Drawing Gesture
    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if vm.currentStroke == nil {
                    vm.startStroke(at: value.location)
                } else {
                    vm.continueStroke(to: value.location)
                }
            }
            .onEnded { _ in
                vm.endStroke()
            }
    }
}
