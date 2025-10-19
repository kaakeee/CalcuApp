//
//  CalculatorButton.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 17/10/2025.
//

import SwiftUI

enum CalculatorButton: String, CaseIterable, Hashable {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"

    case decimal = "."
    case equals = "="

    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"

    case leftParen = "("
    case rightParen = ")"
    case clear = "AC"
    case delete = "DEL"

    var title: String {
        switch self {
        case .delete:
            return "←"
        default:
            return self.rawValue
        }
    }

    // Convertimos backgroundColor en una función que reacciona al tema actual.
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .decimal, .leftParen, .rightParen, .delete:
            // Usamos un color para el modo oscuro y otro para el modo claro.
            return colorScheme == .dark ? Color(.darkGray) : Color(red: 0.92, green: 0.92, blue: 0.92)
        case .clear:
            return colorScheme == .dark ? .gray : Color(red: 0.82, green: 0.82, blue: 0.82)
        case .divide, .multiply, .subtract, .add, .equals:
            // Naranja funciona bien en ambos modos.
            return .orange
        }
    }
    
    // Hacemos lo mismo para el color del texto.
    func foregroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .clear:
            // El texto negro sobre gris se ve bien en ambos temas.
            return .black
        case .divide, .multiply, .subtract, .add, .equals:
            // El texto blanco sobre naranja también.
            return .white
        default:
            // Para los demás botones, el color del texto cambia con el tema.
            return colorScheme == .dark ? .white : .black
        }
    }
}
