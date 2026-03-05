//
//  LogoBadgeView.swift
//  Dayflow
//

import SwiftUI

struct LogoBadgeView: View {
    let imageName: String
    var size: CGFloat = 100
    var action: (() -> Void)? = nil

    @State private var microScale: CGFloat = 1.0
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let currentScale = microScale * (isPressed ? 0.97 : 1.0)
        let cornerRadius = size * 0.22
        let logoShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Image(imageName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .clipShape(logoShape)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
            .frame(width: size, height: size)
            .scaleEffect(currentScale)
            .onAppear {
                guard !reduceMotion else { return }
                microScale = 0.985
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    microScale = 1.0
                }
            }
            .accessibilityHidden(true)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            withAnimation(.easeOut(duration: 0.12)) { isPressed = true }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) { isPressed = false }
                        action?()
                    }
            )
    }
}
