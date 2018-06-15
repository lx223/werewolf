//
//  UINumberPickerView.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

final class UINumberPickerView: UIPickerView {

    var selectedNumber: Int32 {
        let row = self.selectedRow(inComponent: 0)
        return Int32(numOptions[row])
    }

    var numOptions = Array(1...6)

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
}

extension UINumberPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numOptions.count
    }
}
