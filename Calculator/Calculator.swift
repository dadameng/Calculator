import Foundation

protocol Command {
    func execute() -> Decimal
    func undo() -> Decimal
}

class AddCommand: Command {
    private let operand1: Decimal
    private let operand2: Decimal

    init(operand1: Decimal, operand2: Decimal) {
        self.operand1 = operand1
        self.operand2 = operand2
    }

    func execute() -> Decimal {
        return operand1 + operand2
    }

    func undo() -> Decimal {
        return operand1 - operand2
    }
}

class SubtractCommand: Command {
    private let operand1: Decimal
    private let operand2: Decimal

    init(operand1: Decimal, operand2: Decimal) {
        self.operand1 = operand1
        self.operand2 = operand2
    }

    func execute() -> Decimal {
        return operand1 - operand2
    }

    func undo() -> Decimal {
        return operand1 + operand2
    }
}

class MultiplyCommand: Command {
    private let operand1: Decimal
    private let operand2: Decimal

    init(operand1: Decimal, operand2: Decimal) {
        self.operand1 = operand1
        self.operand2 = operand2
    }

    func execute() -> Decimal {
        return operand1 * operand2
    }

    func undo() -> Decimal {
        return operand1 / operand2
    }
}

class DivideCommand: Command {
    private let operand1: Decimal
    private let operand2: Decimal

    init(operand1: Decimal, operand2: Decimal) {
        self.operand1 = operand1
        self.operand2 = operand2
    }

    func execute() -> Decimal {
        return operand1 / operand2
    }

    func undo() -> Decimal {
        return operand1 * operand2
    }
}

class Calculator {
    private var currentResult: Decimal = 0
    private var history: [Command] = []

    func performOperation(_ command: Command) -> Decimal {
        let result = command.execute()
        currentResult = result
        history.append(command)
        return result
    }

    func undoLastOperation() -> Decimal {
        guard let lastCommand = history.popLast() else { return currentResult }
        currentResult = lastCommand.undo()
        return currentResult
    }

    func clearHistory() {
        history.removeAll()
        currentResult = 0
    }

    func getCurrentResult() -> Decimal {
        return currentResult
    }
}
