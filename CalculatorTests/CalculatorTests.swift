//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by dadameng on 2024/05/14.
//

import XCTest
import Combine
@testable import Calculator

final class CalculatorImpTests: XCTestCase {
    private var calculator: CalculatorImp!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        calculator = CalculatorImp()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        calculator = nil
        cancellables = nil
    }

    func testInitialState() throws {
        let expectation1 = XCTestExpectation(description: "Initial resultString")
        let expectation2 = XCTestExpectation(description: "Initial processString")

        calculator.resultStringPublisher
            .sink { value in
                XCTAssertEqual(value, "0")
                expectation1.fulfill()
            }
            .store(in: &cancellables)

        calculator.processStringPublisher
            .sink { value in
                XCTAssertEqual(value, "0")
                expectation2.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation1, expectation2], timeout: 1.0)
    }

    func testNumberPressed() throws {
        let expectation = XCTestExpectation(description: "Number Pressed")

        calculator.resultStringPublisher
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, "1")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.numberPressed("1")
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecimalPressed() throws {
        let expectation = XCTestExpectation(description: "Decimal Pressed")

        calculator.resultStringPublisher
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, "0.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.decimalPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testOperationPressed() throws {
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")

        let expectation = XCTestExpectation(description: "Operation Pressed")

        calculator.resultStringPublisher
            .dropFirst(3)
            .sink { value in
                XCTAssertEqual(value, "3")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testEqualPressed() throws {
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")

        let expectation = XCTestExpectation(description: "Equal Pressed")

        calculator.resultStringPublisher
            .dropFirst(4)
            .sink { value in
                XCTAssertEqual(value, "8")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.equalPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testClearPressed() throws {
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.equalPressed()

        let expectation = XCTestExpectation(description: "Clear Pressed")

        calculator.resultStringPublisher
            .dropFirst(5)
            .sink { value in
                XCTAssertEqual(value, "0")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.clearPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testToggleSign() throws {
        calculator.numberPressed("5")

        let expectation = XCTestExpectation(description: "Toggle Sign")

        calculator.resultStringPublisher
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, "-5")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.toggleSign()
        wait(for: [expectation], timeout: 1.0)
    }

    func testApplyPercentage() throws {
        calculator.numberPressed("50")

        let expectation = XCTestExpectation(description: "Apply Percentage")

        calculator.resultStringPublisher
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, "0.5")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.applyPercentage()
        wait(for: [expectation], timeout: 1.0)
    }

    func testDivisionByZero() throws {
        calculator.numberPressed("5")
        calculator.operationPressed("÷")
        calculator.numberPressed("0")

        let expectation = XCTestExpectation(description: "Division By Zero")

        calculator.resultStringPublisher
            .dropFirst(4)
            .sink { value in
                XCTAssertEqual(value, "Cannot divide by zero")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        calculator.equalPressed()
        wait(for: [expectation], timeout: 1.0)
    }
}
