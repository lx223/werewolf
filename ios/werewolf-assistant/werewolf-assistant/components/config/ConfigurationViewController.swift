//
//  ConfigurationViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 14/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

final class ConfigurationViewController: UIViewController {

    @IBOutlet fileprivate weak var villagerNumberPicker: UINumberPickerView!
    @IBOutlet fileprivate weak var werewolfNumberPicker: UINumberPickerView!
    @IBOutlet fileprivate weak var whiteWerewolfSwitch: UISwitch!
    @IBOutlet fileprivate weak var seerSwitch: UISwitch!
    @IBOutlet fileprivate weak var witchSwitch: UISwitch!
    @IBOutlet fileprivate weak var hunterSwitch: UISwitch!
    @IBOutlet fileprivate weak var confusedSwitch: UISwitch!
    @IBOutlet fileprivate weak var guardSwitch: UISwitch!
    @IBOutlet fileprivate weak var halfBloodSwitch: UISwitch!

    private var roomID: String
    private var userID: String
    fileprivate let gameSrvClient: Werewolf_GameServiceService

    init(roomID: String, userID: String, client: Werewolf_GameServiceService) {
        self.roomID = roomID
        self.userID = userID
        self.gameSrvClient = client

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = R.string.localizable.configSceneTitle()
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: R.string.localizable.configSetConfirmTitle(), style: .done, target: self, action: #selector(self.onConfirmButtonPressed)), animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        villagerNumberPicker.selectRow(2, inComponent: 0, animated: animated)
        werewolfNumberPicker.selectRow(2, inComponent: 0, animated: animated)
        seerSwitch.setOn(true, animated: animated)
        witchSwitch.setOn(true, animated: animated)
        hunterSwitch.setOn(true, animated: animated)
    }
}

fileprivate extension ConfigurationViewController {
    @objc func onConfirmButtonPressed() {
        var req = Werewolf_UpdateGameConfigRequest()
        req.roomID = roomID
        req.roleCounts = Werewolf_Role.allCases.map { getRoleCount(for: $0) }.filter{ $0.count != 0 }

        _ = try? gameSrvClient.updateGameConfig(req) { res, callResult in
            guard res != nil else {
                self.showAlert(for: callResult)
                return
            }
            
            DispatchQueue.main.async {
                let roomViewModel = RoomViewModel(roomID: self.roomID, userID: self.userID, client: self.gameSrvClient)
                let roomController = RoomViewController(viewModel: roomViewModel)
                self.navigationController?.pushViewController(roomController, animated: true)
            }
        }
    }

    func getRoleCount(for role: Werewolf_Role) -> Werewolf_UpdateGameConfigRequest.RoleCount {
        var roleCount = Werewolf_UpdateGameConfigRequest.RoleCount()
        roleCount.role = role
        switch role {
        case .villager:
            roleCount.count = villagerNumberPicker.selectedNumber
        case .werewolf:
            roleCount.count = werewolfNumberPicker.selectedNumber
        case .seer:
            roleCount.count = seerSwitch.isOn ? 1 : 0
        case .witch:
            roleCount.count = witchSwitch.isOn ? 1 : 0
        case .hunter:
            roleCount.count = hunterSwitch.isOn ? 1 : 0
        case .idiot:
            roleCount.count = confusedSwitch.isOn ? 1 : 0
        case .guardian:
            roleCount.count = guardSwitch.isOn ? 1 : 0
        case .whiteWerewolf:
            roleCount.count = whiteWerewolfSwitch.isOn ? 1 : 0
        case .halfBlood:
            roleCount.count = halfBloodSwitch.isOn ? 1 : 0
        default: break
        }
        return roleCount
    }
}
