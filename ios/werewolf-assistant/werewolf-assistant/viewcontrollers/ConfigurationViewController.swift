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

    private var roomID: Int32
    private var userID: String
    fileprivate let gameSrvClient: Werewolf_GameServiceService

    private var roomTitle: String {
        return "房间: \(self.roomID)"
    }

    init(roomID: Int32, userID: String, client: Werewolf_GameServiceService) {
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
        
        self.navigationItem.title = roomTitle
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "确认", style: .done, target: self, action: #selector(self.onConfirmButtonPressed)), animated: false)
    }
}

fileprivate extension ConfigurationViewController {
    @objc func onConfirmButtonPressed() {
        let req = newUpdateGameConfigRequest()

        _ = try? gameSrvClient.updateGameConfig(req) { res, callResult in
            guard callResult.success else {
                self.showAlert(for: callResult)
                return
            }

            let roomController = RoomViewController(roomID: self.roomID, userID: self.userID)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(roomController, animated: true)
            }
        }
    }

    func newUpdateGameConfigRequest() -> Werewolf_UpdateGameConfigRequest {
        var roles = Array<Werewolf_Role>()
        var counts = Array<Int32>()

        roles.append(Werewolf_Role.villager)
        counts.append(villagerNumberPicker.selectedNumber)

        roles.append(Werewolf_Role.werewolf)
        counts.append(werewolfNumberPicker.selectedNumber)

        if whiteWerewolfSwitch.isOn {
            roles.append(Werewolf_Role.whiteWerewolf)
            counts.append(1)
        }

        if seerSwitch.isOn {
            roles.append(Werewolf_Role.seer)
            counts.append(1)
        }

        if witchSwitch.isOn {
            roles.append(Werewolf_Role.witch)
            counts.append(1)
        }

        if hunterSwitch.isOn {
            roles.append(Werewolf_Role.hunter)
            counts.append(1)
        }

        if confusedSwitch.isOn {
            roles.append(Werewolf_Role.idiot)
            counts.append(1)
        }

        if guardSwitch.isOn {
            roles.append(Werewolf_Role.guardian)
            counts.append(1)
        }

        if halfBloodSwitch.isOn {
            roles.append(Werewolf_Role.halfBlood)
            counts.append(1)
        }

        var req = Werewolf_UpdateGameConfigRequest()
        req.roles = roles
        req.counts = counts
        req.userID = userID
        req.roomID = roomID

        return req
    }
}
