import Combine
import Foundation

protocol Calculator {
    var resultStringPublisher: AnyPublisher<String, Never> { get }
    var processStringPublisher: AnyPublisher<String, Never> { get }
    func numberPressed(_ input: String)
    func decimalPressed()
    func operationPressed(_ input: String)
    func equalPressed()
    func clearPressed()
    func toggleSign()
    func applyPercentage()
    func resetInitialValue(_ initialValue: String)
    func deletePressed()
}

final class CalculatorImp {
    private let resultStringSubject = CurrentValueSubject<String, Never>("")
    private let processStringSubject = CurrentValueSubject<String, Never>("")

    var resultStringPublisher: AnyPublisher<String, Never> {
        return resultStringSubject.eraseToAnyPublisher()
    }

    var processStringPublisher: AnyPublisher<String, Never> {
        return processStringSubject.eraseToAnyPublisher()
    }

    private var currentInput: String = ""
    private var previousInput: String = ""
    private var operation: String = ""

    private var processString: String = ""
    private var resultString: String = ""

    enum State {
        case initial
        case enteringNumber
        case operationPressed
        case afterEqual
        case invalidInput
    }

    private var state: State = .initial

    init(initialValue: String = "0") {
        currentInput = initialValue
        state = initialValue == "0" ? .initial : .enteringNumber
        resultStringSubject.send(initialValue)
        processStringSubject.send(initialValue)
    }
}

extension CalculatorImp: Calculator {
    func resetInitialValue(_ initialValue: String) {
        resetStatus(initialValue)
    }

    func numberPressed(_ number: String) {
        ensureValidAndUpdateDisplay {
            if state == .initial || state == .afterEqual {
                operation = ""
                currentInput = number
                state = .enteringNumber
            } else {
                currentInput += number
            }
            resultString = currentInput
        }
    }

    func decimalPressed() {
        ensureValidAndUpdateDisplay {
            if state == .initial {
                currentInput = "0."
                state = .enteringNumber
            } else if state == .afterEqual {
                operation = ""
                currentInput = resultString
                state = .enteringNumber
            }

            if !currentInput.contains(".") {
                currentInput += "."
            }
            resultString = currentInput
        }
    }

    func operationPressed(_ op: String) {
        ensureValidAndUpdateDisplay {
            if state == .enteringNumber {
                operation = op
                previousInput = currentInput
                resultString = currentInput
                currentInput = ""
                state = .operationPressed
            } else if state == .afterEqual {
                operation = op
                previousInput = resultString
                currentInput = ""
                state = .operationPressed
            } else if state == .operationPressed {
                if currentInput.isEmpty {
                    operation = op
                }
            }
        }
    }

    func applyPercentage() {
        ensureValidAndUpdateDisplay {
            if state == .initial {
                currentInput = "0"
            } else {
                var sourceOperator = currentInput
                if state == .afterEqual {
                    sourceOperator = resultString
                }
                guard let value = Decimal(string: sourceOperator) else {
                    showError("Invalid input")
                    return
                }
                currentInput = "\(value / 100)"
                if state == .afterEqual {
                    previousInput = currentInput
                    state = .enteringNumber
                }
            }
            operation = ""
            resultString = currentInput
        }
    }

    func equalPressed() {
        ensureValidAndUpdateDisplay {
            if state == .afterEqual {
                previousInput = resultString
                executeOperation()
            } else if state == .operationPressed {
                if currentInput.isEmpty {
                    currentInput = previousInput
                }
                executeOperation()
            }
        }
    }

    func toggleSign() {
        ensureValidAndUpdateDisplay {
            guard !(state == .operationPressed && currentInput.isEmpty) else {
                return
            }
            var sourceOperator = currentInput
            if state == .afterEqual {
                operation = ""
                state = .enteringNumber
                sourceOperator = resultString
            }
            if sourceOperator.hasPrefix("-") {
                sourceOperator.remove(at: sourceOperator.startIndex)
            } else {
                sourceOperator.insert("-", at: sourceOperator.startIndex)
            }
            currentInput = sourceOperator
            resultString = currentInput
        }
    }

    func clearPressed() {
        resetStatus("0")
    }
    
    func deletePressed() {
        ensureValidAndUpdateDisplay {
            if state == .enteringNumber {
                if !currentInput.isEmpty {
                    currentInput.removeLast()
                } else {
                    state = .initial
                }
                if currentInput.isEmpty {
                    currentInput = "0"
                    state = .initial
                }
            } else if state == .afterEqual {
                currentInput = resultString
                if !currentInput.isEmpty {
                    currentInput.removeLast()
                } else {
                    state = .initial
                }
                operation = ""
                if currentInput.isEmpty {
                    currentInput = "0"
                    state = .initial
                } else {
                    state = .enteringNumber
                }
            } else if state == .operationPressed {
                if currentInput.isEmpty {
                    operation = ""
                    currentInput = previousInput
                    previousInput = ""
                    state = .enteringNumber
                } else {
                    currentInput.removeLast()
                }
            }
            resultString = currentInput
        }
    }

    private func resetStatus(_ initialValue: String) {
        let unformatString = removeCommas(from: initialValue)
        currentInput = unformatString
        resultString = unformatString
        previousInput = ""
        operation = ""
        state = unformatString == "0" ? .initial : .enteringNumber
        updateDisplay()
    }
    
    private func removeCommas(from value: String) -> String {
        return value.replacingOccurrences(of: ",", with: "")
    }

    private func executeOperation() {
        let cleanedPreviousInput = removeCommas(from: previousInput)
        let cleanedCurrentInput = removeCommas(from: currentInput)

        guard let prev = Decimal(string: cleanedPreviousInput), let curr = Decimal(string: cleanedCurrentInput) else {
            showError("Invalid input")
            return
        }
        state = .afterEqual
        var result: Decimal
        switch operation {
        case "+":
            result = prev + curr
        case "−":
            result = prev - curr
        case "×":
            result = prev * curr
        case "÷":
            guard curr != 0 else {
                showError("Cannot divide by zero")
                return
            }
            result = prev / curr
        default:
            showError("Unknown operation")
            return
        }
        resultString = "\(result)"
    }

    private func updateDisplay() {
        if operation.isEmpty {
            processString = currentInput
        } else {
            processString = "\(previousInput) \(operation) \(currentInput)"
        }
        resultStringSubject.send(formatDisplayString(resultString))
        processStringSubject.send(processString)
    }

    private func formatDisplayString(_ value: String) -> String {
        // Check if the value already contains a comma, indicating it has been formatted
        if value.contains(",") {
            return value
        }
        if value.hasSuffix(".") {
             return value
         }
        guard let decimalValue = Decimal(string: value) else {
            return value
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(for: decimalValue) ?? value
    }

    private func showError(_ message: String) {
        resultString = message
        processString = ""
        currentInput = ""
        previousInput = ""
        operation = ""
        state = .invalidInput
    }

    private func ensureValidAndUpdateDisplay(_ block: () -> Void) {
        guard state != .invalidInput else {
            return
        }
        block()
        updateDisplay()
    }
}
