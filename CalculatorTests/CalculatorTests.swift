@testable import Calculator
import Combine
import XCTest

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
        let expectation = XCTestExpectation(description: "Operation Pressed")

        calculator.resultStringPublisher
            .dropFirst(3)
            .sink { value in
                XCTAssertEqual(value, "3")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        wait(for: [expectation], timeout: 1.0)
    }

    func testEqualPressed() throws {
        let expectation = XCTestExpectation(description: "Equal Pressed")

        calculator.resultStringPublisher
            .dropFirst(4)
            .sink { value in
                XCTAssertEqual(value, "8")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.equalPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testResultWhenOnlyOperatorAndPressEqualPressedThenNothing() throws {
        let expectation = XCTestExpectation(description: "Only Operator And Press Equal Pressed")

        calculator.resultStringPublisher
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, "5")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.equalPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testOperationPressedAndDirectPressEqualThenGetResultFromSameOperator() throws {
        let expectation = XCTestExpectation(description: "Operation Pressed And Directly Press Equal")

        calculator.resultStringPublisher
            .dropFirst(3)
            .sink { value in
                XCTAssertEqual(value, "10")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.equalPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testResultWhenOperationPressedAgainAfterEnterNumberThenStillIsCurrentInput() throws {
        let expectation = XCTestExpectation(description: "Operation Pressed Again")

        calculator.resultStringPublisher
            .dropFirst(4)
            .sink { value in
                XCTAssertEqual(value, "3")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.operationPressed("-")
        wait(for: [expectation], timeout: 1.0)
    }

    func testResultWhenEqualPressedAndPressNewNumberThenRestartInput() throws {
        let expectation = XCTestExpectation(description: "Equal Pressed And Press New NumberT")

        calculator.resultStringPublisher
            .dropFirst(5)
            .sink { value in
                XCTAssertEqual(value, "6")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.equalPressed()
        calculator.numberPressed("6")
        wait(for: [expectation], timeout: 1.0)
    }

    func testClearPressed() throws {
        let expectation = XCTestExpectation(description: "Clear Pressed")

        calculator.resultStringPublisher
            .dropFirst(5)
            .sink { value in
                XCTAssertEqual(value, "0")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.equalPressed()
        calculator.clearPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testToggleSign() throws {
        let expectation = XCTestExpectation(description: "Toggle Sign")

        calculator.resultStringPublisher
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, "-5")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.toggleSign()
        wait(for: [expectation], timeout: 1.0)
    }

    func testApplyPercentage() throws {
        let expectation = XCTestExpectation(description: "Apply Percentage")

        calculator.resultStringPublisher
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, "0.5")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("50")
        calculator.applyPercentage()
        wait(for: [expectation], timeout: 1.0)
    }

    func testDivisionByZero() throws {
        let expectation = XCTestExpectation(description: "Division By Zero")

        calculator.resultStringPublisher
            .dropFirst(4)
            .sink { value in
                XCTAssertEqual(value, "Cannot divide by zero")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("÷")
        calculator.numberPressed("0")
        calculator.equalPressed()
        wait(for: [expectation], timeout: 1.0)
    }

    func testDeletePressedEnteringNumber() throws {
        let expectation = XCTestExpectation(description: "Delete Pressed Entering Number")

        calculator.resultStringPublisher
            .dropFirst(3)
            .sink { value in
                XCTAssertEqual(value, "5")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.numberPressed("4")
        calculator.deletePressed()
        wait(for: [expectation], timeout: 1.0)
    }

    // Test deletePressed when state is afterEqual
    func testDeletePressedAfterEqual() throws {
        let expectation = XCTestExpectation(description: "Delete Pressed After Equal")

        // Combine the expectations into a single subscriber
        var receivedValues = [String]()
        calculator.resultStringPublisher
            .dropFirst()
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 5 {
                    XCTAssertEqual(receivedValues[0], "5")
                    XCTAssertEqual(receivedValues[1], "5")
                    XCTAssertEqual(receivedValues[2], "3")
                    XCTAssertEqual(receivedValues[3], "8")
                    XCTAssertEqual(receivedValues[4], "0")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.equalPressed()
        calculator.deletePressed()
        wait(for: [expectation], timeout: 1.0)
    }

    // Test deletePressed when state is operationPressed
    func testDeletePressedOperationPressed() throws {
        let expectation = XCTestExpectation(description: "Delete Pressed Operation Pressed")

        var receivedValues = [String]()
        calculator.resultStringPublisher
            .dropFirst(2)
            .sink { value in
                XCTAssertEqual(value, "5")
            }
            .store(in: &cancellables)

        calculator.resultStringPublisher
            .dropFirst()
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 3 {
                    XCTAssertEqual(receivedValues[0], "5")
                    XCTAssertEqual(receivedValues[1], "5")
                    XCTAssertEqual(receivedValues[2], "5")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.deletePressed()
        wait(for: [expectation], timeout: 1.0)
    }

    // Test deletePressed when currentInput is empty and state is enteringNumber
    func testDeletePressedEnteringNumberEmptyInput() throws {
        let expectation = XCTestExpectation(description: "Delete Pressed Entering Number Empty Input")

        calculator.resultStringPublisher
            .dropFirst(4)
            .sink { value in
                XCTAssertEqual(value, "0")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.numberPressed("4")
        calculator.deletePressed()
        calculator.deletePressed()
        calculator.deletePressed()
        wait(for: [expectation], timeout: 1.0)
    }

    // Test deletePressed when currentInput is empty and state is afterEqual
    func testDeletePressedAfterEqualEmptyInput() throws {
        let expectation = XCTestExpectation(description: "Delete Pressed After Equal Empty Input")

        calculator.resultStringPublisher
            .dropFirst(5)
            .sink { value in
                XCTAssertEqual(value, "0")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.equalPressed()
        calculator.deletePressed() // first delete, should remove 8 and set to 0
        calculator.deletePressed()
        wait(for: [expectation], timeout: 1.0)
    }

    // Test deletePressed when currentInput is empty and state is operationPressed
    func testDeletePressedOperationPressedEmptyInput() throws {
        let expectation = XCTestExpectation(description: "Delete Pressed Operation Pressed Empty Input")

        var receivedValues = [String]()

        calculator.resultStringPublisher
            .dropFirst()
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 5 {
                    XCTAssertEqual(receivedValues[0], "5")
                    XCTAssertEqual(receivedValues[1], "5")
                    XCTAssertEqual(receivedValues[2], "3")
                    XCTAssertEqual(receivedValues[3], "3")
                    XCTAssertEqual(receivedValues[4], "")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        calculator.numberPressed("5")
        calculator.operationPressed("+")
        calculator.numberPressed("3")
        calculator.operationPressed("+")
        calculator.deletePressed()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testResetInitialValueToZero() throws {
            let expectation = XCTestExpectation(description: "Reset to Initial Value 0")
            
            calculator.resultStringPublisher
                .dropFirst() // Drop the initial "0"
                .sink { value in
                    XCTAssertEqual(value, "0")
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            calculator.resetInitialValue("0")
            wait(for: [expectation], timeout: 1.0)
        }

        func testResetInitialValueToNonZero() throws {
            let expectation = XCTestExpectation(description: "Reset to Initial Value 12345")
            
            calculator.resultStringPublisher
                .dropFirst() // Drop the initial "0"
                .sink { value in
                    XCTAssertEqual(value, "12,345")
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            calculator.resetInitialValue("12345")
            wait(for: [expectation], timeout: 1.0)
        }

        func testResetInitialValueToFormattedNonZero() throws {
            let expectation = XCTestExpectation(description: "Reset to Initial Value 12345 with Comma")
            
            calculator.resultStringPublisher
                .dropFirst() // Drop the initial "0"
                .sink { value in
                    XCTAssertEqual(value, "12,345")
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            calculator.resetInitialValue("12,345")
            wait(for: [expectation], timeout: 1.0)
        }

        func testResetInitialValueUpdatesProcessString() throws {
            let expectation = XCTestExpectation(description: "Process String Updated on Reset")
            
            calculator.processStringPublisher
                .dropFirst() // Drop the initial "0"
                .sink { value in
                    XCTAssertEqual(value, "12345")
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            calculator.resetInitialValue("12,345")
            wait(for: [expectation], timeout: 1.0)
        }
}
