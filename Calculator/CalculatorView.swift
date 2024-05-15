import SnapKit
import UIKit
import Factory
import Combine

final class CalculatorView: UIView {
    private var processLabel: UILabel!
    private var resultLabel: UILabel!
    private var buttonContainerView: UIView!
    private var buttons: [[UIButton]] = []
    private let padding: CGFloat = 10
    private let buttonCornerRadius = 15.0
    
    private var calculator: Calculator
    private var cancellables = Set<AnyCancellable>()

    // 使用依赖注入的初始化方法
    init(frame: CGRect, initialValue: String) {
        self.calculator = Container.shared.calculator(initialValue)
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .black
        setupLabels()
        setupButtons()
        calculator.resultStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.resultLabel.text = result
            }
            .store(in: &cancellables)

        calculator.processStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] process in
                self?.processLabel.text = process
            }
            .store(in: &cancellables)
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
            calculator.numberPressed(title)
        case ".":
            calculator.decimalPressed()
        case "+", "−", "×", "÷":
            calculator.operationPressed(title)
        case "=":
            calculator.equalPressed()
        case "C":
            calculator.clearPressed()
        case "±":
            calculator.toggleSign()
        case "%":
            calculator.applyPercentage()
        default:
            break
        }
    }
}
