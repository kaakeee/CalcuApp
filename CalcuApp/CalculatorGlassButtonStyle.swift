// CalculatorGlassButtonStyle.swift

import SwiftUI

struct CalculatorGlassButtonStyle: ButtonStyle {
    // Necesitamos saber qué botón es para aplicar su color específico.
    var button: CalculatorButton
    // El tamaño se calcula en la vista principal, así que lo pasamos como parámetro.
    var size: CGFloat
    // También necesitamos el esquema de color para la adaptabilidad.
    var colorScheme: ColorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 32))
            .frame(width: size, height: size)
            .foregroundColor(button.foregroundColor(for: colorScheme))
            .background(
                // El material ultrafino es la base del efecto cristal.
                .ultraThinMaterial, in: Circle()
            )
            // Superponemos una capa del color original del botón con algo de opacidad.
            .overlay(
                Circle()
                    .fill(button.backgroundColor(for: colorScheme).opacity(0.4))
            )
            // Añadimos un borde sutil para que el botón resalte un poco.
            .overlay(
                 Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            // Nos aseguramos de que toda la vista tenga la forma de un círculo.
            .clipShape(Circle())
            // Efecto de escala al presionar.
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
