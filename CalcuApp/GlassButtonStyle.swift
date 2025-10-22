// GlassButtonStyle.swift

import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            // El fondo de material es lo que crea el efecto de cristal translúcido.
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            // Añadimos un borde sutil que también se adapta.
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            // Hacemos que el botón se encoja un poco al presionarlo.
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
