import SnapKit
import UIKit

class CalculatorView: UIView {
    private var processLabel: UILabel!
    private var resultLabel: UILabel!
    private var buttonContainerView: UIView!
    private var buttons: [[UIButton]] = []

    private var currentInput: String = ""
    private var previousInput: String = ""
    private var operation: String = ""

    private let calculator = Calculator()
    private let padding: CGFloat = 10
    private let buttonCornerRadius = 15.0

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
            decimalInput()
        case "+", "−", "×", "÷":
            operationPressed(title)
        case "=":
            equalsPressed()
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
        if currentInput == "0" && number != "." {
            currentInput = ""
        }
        currentInput += number
        resultLabel.text = currentInput
        updateProcessLabel()
    }

    private func decimalInput() {
        if currentInput.isEmpty || currentInput == "0" {
            currentInput = "0."
        } else if !currentInput.contains(".") {
            currentInput += "."
        }
        resultLabel.text = currentInput
        updateProcessLabel()
    }
    
    private func operationPressed(_ op: String) {
        operation = op
        previousInput = currentInput
        currentInput = ""
        updateProcessLabel()
    }

    private func applyPercentage() {
        if currentInput.isEmpty || currentInput == "0" {
            currentInput = "0.00"
        } else {
            guard let value = Decimal(string: currentInput) else {
                showError("Invalid input")
                return
            }
            currentInput = "\(value / 100)"
        }
        resultLabel.text = currentInput
        updateProcessLabel()
    }

    private func updateProcessLabel() {
        if operation.isEmpty {
            processLabel.text = currentInput
        } else {
            processLabel.text = "\(previousInput) \(operation) \(currentInput)"
        }
    }

    private func equalsPressed() {
        guard let prev = Decimal(string: previousInput), let curr = Decimal(string: currentInput) else {
            showError("Invalid input")
            return
        }
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
        resultLabel.text = "\(result)"
        processLabel.text = "\(previousInput) \(operation) \(currentInput)"
        currentInput = "\(result)"
    }

    private func clearPressed() {
        calculator.clearHistory()
        resultLabel.text = "0"
        processLabel.text = ""
        currentInput = ""
        previousInput = ""
        operation = ""
    }

    private func toggleSign() {
        if currentInput.hasPrefix("-") {
            currentInput.remove(at: currentInput.startIndex)
        } else {
            currentInput.insert("-", at: currentInput.startIndex)
        }
        resultLabel.text = currentInput
    }

    private func showError(_ message: String) {
        resultLabel.text = message
        currentInput = ""
        previousInput = ""
        operation = ""
    }
}
