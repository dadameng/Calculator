//
//  ViewController.swift
//  Calculator
//
//  Created by dadameng on 2024/05/14.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        let calculatorView = CalculatorView(frame: CGRectZero, initialValue: "0")
        view.addSubview(calculatorView)
        
        calculatorView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }


}

