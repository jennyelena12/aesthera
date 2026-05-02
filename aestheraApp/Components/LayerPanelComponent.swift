//
//  LayerPanelComponent.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//

import SwiftUI

struct LayerPanelComponent: View {

    @Bindable var vm: CanvasViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header row
            HStack {
                Text("Layers")
                    .font(.headline)
                Spacer()
                // Add layer button
                Button {
                    vm.addLayer()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }

            Divider()

            // List of layers (reversed so top layer shows first)
            ForEach(vm.layers.indices.reversed(), id: \.self) { index in
                HStack {
                    // Active indicator dot
                    Circle()
                        .fill(index == vm.activeLayerIndex ? Color.blue : Color.clear)
                        .frame(width: 8, height: 8)

                    Text(vm.layers[index].name)
                        .font(.subheadline)
                    
                    Spacer()

                    // Delete button (only if more than 1 layer)
                    if vm.layers.count > 1 {
                        Button {
                            vm.deleteLayer(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .contentShape(Rectangle())       // makes whole row tappable
                .onTapGesture {
                    vm.activeLayerIndex = index   // switch active layer
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
