//
//  ViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 11/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit
import SwiftGRPC

class ViewController: UIViewController {

    private var roomSrvClient: Werewolf_GameServiceService  = Werewolf_GameServiceServiceClient(address:"localhost:8080", secure: false, arguments: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onCreateRoomButtonPressed(_ sender: UIButton) {
        _ = try? roomSrvClient.createAndJoinRoom(Werewolf_CreateAndJoinRoomRequest()){ createRoomResponse, callResult in
            guard let roomID = createRoomResponse?.roomID, let userID = createRoomResponse?.userID  else {
                self.showAlert(for: callResult)
                return
            }

            let configController = ConfigurationViewController(roomID: roomID, userID: userID)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(configController, animated: true)
            }
        }
    }

    @IBAction func onJoinRoomButtonPressed(_ sender: UIButton) {
        let joinRoomAlert = UIAlertController(title: nil, message: "请输入房间号", preferredStyle: .alert)
        joinRoomAlert.addTextField(configurationHandler: nil)
        joinRoomAlert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        joinRoomAlert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak joinRoomAlert] (_) in
            guard let text = joinRoomAlert?.textFields?.first?.text, let roomId = Int32(text) else {
                self.showAlert(for: nil, orMessage: "请输入数字")
                return
            }

            var joinRoomRequest = Werewolf_JoinRoomRequest()
            joinRoomRequest.roomID = roomId
            _ = try? self.roomSrvClient.joinRoom(joinRoomRequest) { joinRoomResponse, callResult in

                guard let userID = joinRoomResponse?.userID else {
                    self.showAlert(for: callResult)
                    return
                }

                let roomController: RoomViewController = RoomViewController(roomID: roomId, userID: userID)
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(roomController, animated: true)
                }
            }
        }))

        self.present(joinRoomAlert, animated: true, completion: nil)
    }

    func showAlert(for callResult: CallResult?, orMessage msg: String? = nil) {
        DispatchQueue.main.async {
            let errMsg = callResult?.statusMessage ?? msg
            let alert = UIAlertController(title: nil, message: errMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "👌", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

