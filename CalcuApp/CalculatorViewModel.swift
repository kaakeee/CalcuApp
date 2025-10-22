//
//  CalculatorViewModel.swift
//  CalcuApp
//
//  Created by Ramiro Nehuen Sanabria on 17/10/2025.
//

import Foundation
import Combine

class CalculatorViewModel: ObservableObject {
    @Published var display = "0"
    @Published var history: [String] = []

    func buttonTapped(_ button: CalculatorButton) {
        // Manejar el estado de error: solo permitir borrar o empezar un nuevo cálculo.
        if display == "Error" {
            if button == .clear || button == .delete {
                display = "0"
                return
            }
            
            switch button {
            // Estos botones inician un nuevo cálculo.
            case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .leftParen, .decimal:
                display = button.title
                return
            // Los demás botones no hacen nada en estado de error.
            default:
                return
            }
        }

        switch button {
        case .clear:
            display = "0"
        case .equals:
            calculate()
        case .percent: // <-- Añadido caso para el porcentaje
            handlePercent()
        case .decimal:
            // Prevenir múltiples puntos decimales en el mismo número.
            let lastComponent = display.components(separatedBy: CharacterSet(charactersIn: "+-×÷()")).last ?? ""
            if !lastComponent.contains(".") {
                display += button.title
            }
        case .delete:
            if display.count > 1 {
                display.removeLast()
            } else {
                display = "0"
            }
        
        case .add, .subtract, .multiply, .divide:
            guard let lastChar = display.last else { return }

            // No permitir un operador justo después de un paréntesis de apertura (excepto para números negativos).
            if lastChar == "(" && button != .subtract {
                return
            }
            
            // Si el último carácter ya es un operador, reemplazarlo.
            if isOperator(character: lastChar) {
                display.removeLast()
            }
            
            display += button.title
            
        case .rightParen:
            let openParenCount = display.filter { $0 == "(" }.count
            let closeParenCount = display.filter { $0 == ")" }.count
            // Solo añadir un paréntesis de cierre si hay más paréntesis de apertura que de cierre.
            if openParenCount > closeParenCount {
                display += button.title
            }

        case .leftParen, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if display == "0" {
                display = button.title
            } else {
                display += button.title
            }
        }
    }

    private func isOperator(_ button: CalculatorButton) -> Bool {
        switch button {
        case .add, .subtract, .multiply, .divide:
            return true
        default:
            return false
        }
    }
    
    private func isOperator(character: Character) -> Bool {
        return ["+", "-", "×", "÷"].contains(character)
    }

    private func addImplicitMultiplication(to expression: String) -> String {
        var result = expression
        result = result.replacingOccurrences(of: "([0-9\\)])\\(", with: "$1*(", options: .regularExpression)
        return result
    }
    
    // <-- Nueva función para manejar la lógica del porcentaje
    private func handlePercent() {
        // Busca el último número en la pantalla.
        let components = display.components(separatedBy: CharacterSet(charactersIn: "+-×÷()"))
        guard let lastComponent = components.last, !lastComponent.isEmpty else {
            return
        }

        // Convierte el número a Double, lo divide por 100 y lo vuelve a convertir a String.
        if let number = Double(lastComponent) {
            let result = number / 100.0
            
            let resultString: String
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                resultString = String(format: "%.0f", result)
            } else {
                resultString = String(result)
            }
            
            // Reemplaza el número original por su valor en porcentaje.
            if let range = display.range(of: lastComponent, options: .backwards) {
                display.replaceSubrange(range, with: resultString)
            }
        }
    }
    
    private func calculate() {
        let originalExpression = display
        
        var sanitizedExpression = originalExpression
        while let lastChar = sanitizedExpression.last, ["+", "-", "×", "÷", "(", "."].contains(lastChar) {
            sanitizedExpression.removeLast()
        }
        
        guard !sanitizedExpression.isEmpty else { return }

        var expressionWithMultiplication = addImplicitMultiplication(to: sanitizedExpression)

        let openParenCount = expressionWithMultiplication.filter { $0 == "(" }.count
        let closeParenCount = expressionWithMultiplication.filter { $0 == ")" }.count

        if openParenCount > closeParenCount {
            expressionWithMultiplication += String(repeating: ")", count: openParenCount - closeParenCount)
        }
        
        let expressionToEvaluate = expressionWithMultiplication
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !expressionToEvaluate.isEmpty else {
            return
        }
        
        let expression = NSExpression(format: expressionToEvaluate)

        do {
            if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                let resultString: String
                if result.truncatingRemainder(dividingBy: 1) == 0 {
                    resultString = String(format: "%.0f", result)
                } else {
                    resultString = String(result)
                }
                
                let historyEntry = "\(expressionWithMultiplication) = \(resultString)"
                history.append(historyEntry)
                
                display = resultString
                
            } else {
                display = "Error"
            }
        } catch {
            display = "Error"
        }
    }
    
    func clearHistory() {
        history.removeAll()
    }
}
