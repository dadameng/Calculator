import Foundation
import Factory

extension Container {
    var calculator: ParameterFactory<String, Calculator> {
        ParameterFactory(self) { initialValue in
            CalculatorImp(initialValue: initialValue)
        }
    }
}
