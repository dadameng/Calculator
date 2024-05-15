import SnapKit
import UIKit

class CalculatorView: UIView {
    private var processLabel: UILabel!
    private var resultLabel: UILabel!
    private var buttonContainerView: UIView!
    private var buttons: [[UIButton]] = []
    private let calculator = Calculator()
    private let padding: CGFloat = 10
    private let buttonCornerRadius = 15.0

    private var currentInput: String = ""
    private var previousInput: String = ""
    private var resultString: String = ""
    private var operation: String = ""
    private var isNegative = false
    
    enum State {
        case initial
        case enteringNumber
        case operationPressed
        case afterEqual
        case invalidInput
    }

    private var state: State = .initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .black
        setupLabels()
        setupButtons()
    }

    private func setupLabels() {
        processLabel = UILabel()
        resultLabel = UILabel()

        processLabel.textAlignment = .right
        processLabel.contentMode = .bottom
        resultLabel.textAlignment = .right
        resultLabel.contentMode = .bottom

        processLabel.font = UIFont.systemFont(ofSize: 24)
        resultLabel.font = UIFont.systemFont(ofSize: 48)

        processLabel.textColor = .white
        resultLabel.textColor = .white
        processLabel.text = "0"
        resultLabel.text = "0"

        addSubview(processLabel)
        addSubview(resultLabel)

        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(padding)
            make.left.right.equalTo(self).inset(padding)
        }

        processLabel.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom).offset(padding)
            make.left.right.equalTo(self).inset(padding)
            make.height.equalTo(resultLabel.snp.height).multipliedBy(0.5)
        }
        resultLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        resultLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    private func setupButtons() {
        let buttonTitles = [
            ["C", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", ".", "="],
        ]
        buttonContainerView = UIView()
        addSubview(buttonContainerView)
        buttonContainerView.snp.makeConstraints { make in
            make.top.equalTo(processLabel.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
        buttonContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        buttonContainerView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        for row in buttonTitles {
            var buttonRow: [UIButton] = []
            for title in row {
                let button = createButton(title: title)
                buttonContainerView.addSubview(button)
                buttonRow.append(button)
            }
            buttons.append(buttonRow)
        }

        layoutButtons()
    }

    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)

        if "0" ... "9" ~= title || title == "." {
            button.backgroundColor = UIColor(hex: "#1C1C1C")
            button.setTitleColor(.white, for: .normal)
        } else if title == "C" || title == "±" || title == "%" {
            button.backgroundColor = UIColor(hex: "#505050")
            button.setTitleColor(.black, for: .normal)
        } else {
            button.backgroundColor = UIColor(hex: "#FF9500")
            button.setTitleColor(.white, for: .normal)
        }
        button.layer.cornerRadius = buttonCornerRadius
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        return button
    }

    private func layoutButtons() {
        for (rowIndex, row) in buttons.enumerated() {
            for (buttonIndex, button) in row.enumerated() {
                button.snp.makeConstraints { make in
                    if rowIndex == 4 && buttonIndex == 0 {
                        make.width.equalTo(self.snp.width).multipliedBy(0.5).offset(-2 * padding)
                        make.height.equalTo(self.snp.width).dividedBy(4).offset(-1.5 * padding)
                    } else {
                        make.width.equalTo(self.snp.width).dividedBy(4).offset(-1.5 * padding)
                        make.height.equalTo(button.snp.width)
                    }

                    if rowIndex == 0 {
                        make.top.equalTo(processLabel.snp.bottom).offset(padding)
                    } else {
                        make.top.equalTo(buttons[rowIndex - 1][0].snp.bottom).offset(padding)
                    }

                    if buttonIndex == 0 {
                        make.left.equalToSuperview().offset(padding)
                    } else {
                        make.left.equalTo(row[buttonIndex - 1].snp.right).offset(padding)
                    }

                    if rowIndex == buttons.count - 1 && buttonIndex == row.count - 1 {
                        make.bottom.equalToSuperview().offset(-padding)
                    }
                }
            }
        }
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }

        switch title {
        case "0" ... "9":
            numberPressed(title)
        case ".":
            decimalPressed()
        case "+", "−", "×", "÷":
            operationPressed(title)
        case "=":
            equalPressed()
        case "C":
            clearPressed()
        case "±":
            toggleSign()
        case "%":
            applyPercentage()
        default:
            break
        }
    }

    private func numberPressed(_ number: String) {
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

    private func decimalPressed() {
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

    private func operationPressed(_ op: String) {
        ensureValidAndUpdateDisplay {
            if state == .enteringNumber {
                operation = op
                previousInput = currentInput
                resultString = currentInput
                currentInput = ""
                state = .operationPressed
            }  else if state == .afterEqual {
                operation = op
                previousInput = resultString
                currentInput = ""
                state = .operationPressed
            } else if state == .operationPressed {
                operation = op
            }
        }
    }

    private func applyPercentage() {
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

    private func equalPressed() {
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

    private func executeOperation() {
        guard let prev = Decimal(string: previousInput), let curr = Decimal(string: currentInput) else {
            showError("Invalid input")
            return
        }
        state = .afterEqual
        let command: Command
        switch operation {
        case "+":
            command = AddCommand(operand1: prev, operand2: curr)
        case "−":
            command = SubtractCommand(operand1: prev, operand2: curr)
        case "×":
            command = MultiplyCommand(operand1: prev, operand2: curr)
        case "÷":
            guard curr != 0 else {
                showError("Cannot divide by zero")
                return
            }
            command = DivideCommand(operand1: prev, operand2: curr)
        default:
            showError("Unknown operation")
            return
        }
        let result = calculator.performOperation(command)
        resultString = "\(result)"
    }

    private func toggleSign() {
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
    
    private func clearPressed() {
        currentInput = "0"
        resultString = "0"
        previousInput = ""
        operation = ""
        state = .initial
        updateDisplay()
    }

    private func updateDisplay() {
        if operation.isEmpty {
            processLabel.text = currentInput
        } else {
            processLabel.text = "\(previousInput) \(operation) \(currentInput)"
        }
        resultLabel.text = resultString
    }

    private func showError(_ message: String) {
        resultString = message
        resultLabel.text = message
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
