import UIKit
import SnapKit

class CalculatorView: UIView {
    
    private var processLabel: UILabel!
    private var resultLabel: UILabel!
    private var buttons: [[UIButton]] = []
    
    private var currentInput: String = ""
    private var previousInput: String = ""
    private var operation: String = ""
    
    private let calculator = Calculator()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        processLabel = UILabel()
        resultLabel = UILabel()
        
        processLabel.textAlignment = .right
        resultLabel.textAlignment = .right
        
        processLabel.font = UIFont.systemFont(ofSize: 24)
        resultLabel.font = UIFont.systemFont(ofSize: 48)
        
        processLabel.textColor = .gray
        resultLabel.textColor = .black
        
        addSubview(processLabel)
        addSubview(resultLabel)
        
        processLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.left.right.equalTo(self).inset(20)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(processLabel.snp.bottom).offset(10)
            make.left.right.equalTo(self).inset(20)
        }
        
        let buttonTitles = [
            ["C", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", ".", "="]
        ]
        
        for row in buttonTitles {
            var buttonRow: [UIButton] = []
            for title in row {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 10
                button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
                addSubview(button)
                buttonRow.append(button)
            }
            buttons.append(buttonRow)
        }
        
        layoutButtons()
    }
    
    private func layoutButtons() {
        let padding: CGFloat = 10
        for (rowIndex, row) in buttons.enumerated() {
            for (buttonIndex, button) in row.enumerated() {
                button.snp.makeConstraints { make in
                    if rowIndex == 4 && buttonIndex == 0 {
                        make.width.equalTo(self.frame.width / 2 - 1.5 * padding)
                    } else {
                        make.width.equalTo(self.frame.width / 4 - 1.5 * padding)
                    }
                    make.height.equalTo(self.frame.width / 4 - 1.5 * padding)
                    if rowIndex == 0 {
                        make.top.equalTo(resultLabel.snp.bottom).offset(padding)
                    } else {
                        make.top.equalTo(buttons[rowIndex - 1][0].snp.bottom).offset(padding)
                    }
                    if buttonIndex == 0 {
                        make.left.equalTo(self).offset(padding)
                    } else {
                        make.left.equalTo(row[buttonIndex - 1].snp.right).offset(padding)
                    }
                }
            }
        }
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        
        switch title {
        case "0"..."9", ".":
            numberPressed(title)
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
        currentInput += number
        resultLabel.text = currentInput
    }
    
    private func operationPressed(_ op: String) {
        operation = op
        previousInput = currentInput
        currentInput = ""
        processLabel.text = "\(previousInput) \(operation)"
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
        processLabel.text = "\(previousInput) \(operation) \(currentInput) ="
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
    
    private func applyPercentage() {
        guard let value = Decimal(string: currentInput) else {
            showError("Invalid input")
            return
        }
        currentInput = "\(value / 100)"
        resultLabel.text = currentInput
    }
    
    private func showError(_ message: String) {
        resultLabel.text = message
        currentInput = ""
        previousInput = ""
        operation = ""
    }
}
