//
//  ToolbarComponent.swift
//  aestheraApp
//
//  Created by Elena Nathanielle on 02/05/26.
//

import SwiftUI

struct ToolbarComponent: View {

    @Bindable var vm: CanvasViewModel  // @Bindable lets us read AND write to vm

    var body: some View {
        VStack(spacing: 16) {

            // Pen / Eraser toggle
            HStack(spacing: 12) {
                ToolButton(icon: "pencil", label: "Pen", isActive: !vm.isEraser) {
                    vm.isEraser = false
                }
                ToolButton(icon: "eraser", label: "Eraser", isActive: vm.isEraser) {
                    vm.isEraser = true
                }
            }

            Divider()

            // Opacity Slider (only shows for eraser to keep it simple)
            if vm.isEraser {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Eraser Opacity")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: $vm.opacity, in: 0.1...1.0)
                        .tint(.primary)
                }
                .padding(.horizontal, 8)
            }

            // Brush size
            VStack(alignment: .leading, spacing: 4) {
                Text("Size: \(Int(vm.lineWidth))pt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $vm.lineWidth, in: 2...40)
                    .tint(.primary)
            }
            .padding(.horizontal, 8)

            // Color picker (only for pen)
            if !vm.isEraser {
                ColorPicker("Color", selection: $vm.strokeColor)
                    .padding(.horizontal, 8)
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Small reusable tool button
struct ToolButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isActive ? Color.primary : Color.clear)
            .foregroundStyle(isActive ? Color(.systemBackground) : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
