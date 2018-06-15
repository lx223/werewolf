//
//  ConfigurationViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 14/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

final class ConfigurationViewController: UIViewController {

    @IBOutlet weak var villagerNumberPicker: UIPickerView!
    @IBOutlet weak var werewolfNumberPicker: UIPickerView!
    @IBOutlet weak var whiteWerewolfSwitch: UISwitch!
    @IBOutlet weak var seerSwitch: UISwitch!
    @IBOutlet weak var witchSwitch: UISwitch!
    @IBOutlet weak var hunterSwitch: UISwitch!
    @IBOutlet weak var confusedSwitch: UISwitch!
    @IBOutlet weak var guardSwitch: UISwitch!
    @IBOutlet weak var halfBloodSwitch: UISwitch!

    fileprivate let numberPickerOptions = Array(1...10)

    private var roomID: Int32
    private var userID: String

    init(roomID: Int32, userID: String) {
        self.roomID = roomID
        self.userID = userID

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "设置配置"
    }
}

extension ConfigurationViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberPickerOptions.count
    }
}

extension ConfigurationViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numberPickerOptions[row])"
    }
}
