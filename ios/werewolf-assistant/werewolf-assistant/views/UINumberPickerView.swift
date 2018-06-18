//
//  UINumberPickerView.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

@IBDesignable
final class UINumberPickerView: UIPickerView {

    @IBInspectable var lowestNumber: Int = 0
    @IBInspectable var highestNumber: Int = 6

    var selectedNumber: Int32 {
        let row = self.selectedRow(inComponent: 0)
        return Int32(numOptions[row])
    }

    var numOptions: [Int] {
        return Array(lowestNumber...highestNumber)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.delegate = self
        self.dataSource = self
    }
}

extension UINumberPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numOptions[row])"
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let optionView = view as? UILabel ?? UILabel()
        optionView.text = "\(numOptions[row])"
        optionView.textAlignment = .center
        let hue = CGFloat(row) / CGFloat(numOptions.count)
        optionView.backgroundColor = UIColor(hue: hue, saturation: 0.8, brightness:0.8, alpha: 0.8)
        return optionView
    }
}

extension UINumberPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numOptions.count
    }
}
