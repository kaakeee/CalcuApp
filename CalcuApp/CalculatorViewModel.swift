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
        switch button {
        case .clear:
            display = "0"
        case .equals:
            calculate()
        case .decimal:
            // Prevent adding multiple decimals in the same number component.
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
        case .add, .subtract, .multiply, .divide, .leftParen, .rightParen, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if display == "0" && !isOperator(button) {
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
    
    private func calculate() {
        let originalExpression = display
        // NSExpression doesn't understand '×' and '÷', so we replace them.
        let expressionToEvaluate = originalExpression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            // Ensure the expression is not empty or just an operator to avoid crashes
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !expressionToEvaluate.isEmpty else {
            return
        }
        
        // Use NSExpression to evaluate the string.
        let expression = NSExpression(format: expressionToEvaluate)

        do {
            if let result = expression.expressionValue(with: nil, context: nil) as? Double {
                let resultString: String
                // Format the result to remove trailing .0 for whole numbers.
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
