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
            
        case .leftParen, .rightParen, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if display == "0" {
                // No permitir que la expresión empiece con ')'
                if button != .rightParen {
                    display = button.title
                }
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
    
    // Nueva función auxiliar para comprobar si un carácter es un operador.
    private func isOperator(character: Character) -> Bool {
        return ["+", "-", "×", "÷"].contains(character)
    }
    
    private func calculate() {
        let originalExpression = display
        // NSExpression no entiende '×' y '÷', así que los reemplazamos.
        let expressionToEvaluate = originalExpression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            // Asegurarse de que la expresión no esté vacía o sea solo un operador para evitar fallos.
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !expressionToEvaluate.isEmpty else {
            return
        }
        
        // Usar NSExpression para evaluar la cadena.
        let expression = NSExpression(format: expressionToEvaluate)

        do {
            if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                let resultString: String
                // Formatear el resultado para quitar el .0 en números enteros.
                if result.truncatingRemainder(dividingBy: 1) == 0 {
                    resultString = String(format: "%.0f", result)
                } else {
                    resultString = String(result)
                }
                
                let historyEntry = "\(originalExpression) = \(resultString)"
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
