import SnapKit
import UIKit
import Combine

class ViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()

    let calculatorView1 = CalculatorView(frame: .zero, initialValue: "0")
    let calculatorView2 = CalculatorView(frame: .zero, initialValue: "0")
    let buttonContainerView = UIView()
    let button1 = UIButton(type: .system)
    let button2 = UIButton(type: .system)
    let button3 = UIButton(type: .system)
    var currentOperatedCalculator: CalculatorView?
    
    let padding: CGFloat = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        view.addSubview(calculatorView1)
        view.addSubview(calculatorView2)
        view.addSubview(buttonContainerView)

        buttonContainerView.addSubview(button1)
        buttonContainerView.addSubview(button2)
        buttonContainerView.addSubview(button3)

        setupButtons()
        setupInitialConstraints()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        calculatorView1.buttonPressedPublisher
            .sink { [weak self] in
                self?.handleButtonPress(from: self?.calculatorView1)
            }
            .store(in: &subscriptions)

        calculatorView2.buttonPressedPublisher
            .sink { [weak self] in
                self?.handleButtonPress(from: self?.calculatorView2)
            }
            .store(in: &subscriptions)
    }
    private func handleButtonPress(from calculatorView: CalculatorView?) {
        guard let calculatorView = calculatorView else { return }
        currentOperatedCalculator = calculatorView
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateConstraints(for: size)
        })
    }

    private func setupInitialConstraints() {
        calculatorView1.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        calculatorView2.isHidden = true
        buttonContainerView.isHidden = true
    }

    private func setupButtons() {
        let buttonCornerRadius = 15.0
        let leftArrowImage = UIImage.drawThickArrow(direction: "left", size: CGSize(width: 25, height: 25))
        let rightArrowImage = UIImage.drawThickArrow(direction: "right", size: CGSize(width: 25, height: 25))

        button1.setImage(leftArrowImage, for: .normal)
        button2.setImage(rightArrowImage, for: .normal)
        button1.addTarget(self, action: #selector(resetCalculator1), for: .touchUpInside)
        button2.addTarget(self, action: #selector(resetCalculator2), for: .touchUpInside)

        let buttons = [button1, button2]

        for button in buttons {
            button.tintColor = .white
            button.backgroundColor = UIColor(hex: "#4CAF50")
            button.layer.cornerRadius = buttonCornerRadius
            button.clipsToBounds = true
        }

        button3.setTitle("DEL", for: .normal)
        button3.tintColor = .white
        button3.backgroundColor = UIColor(hex: "#505050")
        button3.layer.cornerRadius = buttonCornerRadius
        button3.clipsToBounds = true
        button3.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
    }

    @objc private func resetCalculator1() {
        calculatorView1.resetInitialValue(calculatorView2.extractResult())
    }

    @objc private func resetCalculator2() {
        calculatorView2.resetInitialValue(calculatorView1.extractResult())
    }

    @objc private func deletePressed() {
        currentOperatedCalculator?.deletePressed()
    }

    private func updateConstraints(for size: CGSize) {
        let isPortrait = size.height > size.width

        calculatorView1.snp.removeConstraints()
        calculatorView2.snp.removeConstraints()
        buttonContainerView.snp.removeConstraints()
        button1.snp.removeConstraints()
        button2.snp.removeConstraints()
        button3.snp.removeConstraints()

        if isPortrait {
            calculatorView1.snp.remakeConstraints { make in
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
            calculatorView2.isHidden = true
            buttonContainerView.isHidden = true
        } else {
            calculatorView1.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
                make.leading.equalTo(view.safeAreaLayoutGuide).offset(padding)
                make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.3) // Adjusted for button container
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            }

            buttonContainerView.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
                make.centerX.equalToSuperview()
                make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.1)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            }

            let buttonHeightMultiplier: CGFloat = 2 / 3

            button1.snp.makeConstraints { make in
                make.top.equalTo(buttonContainerView.snp.top).offset(padding)
                make.centerX.equalTo(buttonContainerView)
                make.width.equalTo(buttonContainerView.snp.width).multipliedBy(buttonHeightMultiplier).offset(-padding)
                make.height.equalTo(button1.snp.width)
            }

            button2.snp.makeConstraints { make in
                make.top.equalTo(button1.snp.bottom).offset(padding)
                make.centerX.equalTo(buttonContainerView)
                make.width.equalTo(button1.snp.width)
                make.height.equalTo(button2.snp.width)
            }

            button3.snp.makeConstraints { make in
                make.centerX.equalTo(buttonContainerView)
                make.width.equalTo(button1.snp.width)
                make.height.equalTo(button3.snp.width)
                make.bottom.equalTo(buttonContainerView.snp.bottom).offset(-padding)
            }

            calculatorView2.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
                make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-padding)
                make.leading.equalTo(buttonContainerView.snp.trailing).offset(padding)
                make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.3) // Adjusted for button container
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-padding)
            }

            calculatorView2.isHidden = false
            buttonContainerView.isHidden = false
        }
    }
}
