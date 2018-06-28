//
//  ViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 11/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit
import SwiftGRPC
import SwiftySound

class ViewController: UIViewController {

    private var gameSrvClient: Werewolf_GameServiceService  = {
        let client = Werewolf_GameServiceServiceClient(address:Constants.serverAddress, secure: false, arguments: [])
        try! client.metadata.add(key: "x-api-key", value: Constants.googleAPIKey)
        return client
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationItem.title = "大厅"
        navigationController?.isNavigationBarHidden = false
    }

    @IBAction func onCreateRoomButtonPressed(_ sender: UIButton) {
        _ = try? gameSrvClient.createAndJoinRoom(Werewolf_CreateAndJoinRoomRequest()){ createRoomResponse, callResult in
            guard let roomID = createRoomResponse?.roomID, let userID = createRoomResponse?.userID  else {
                self.showAlert(for: callResult)
                return
            }

            let configController = ConfigurationViewController(roomID: roomID, userID: userID, client: self.gameSrvClient)
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
            guard let roomId = joinRoomAlert?.textFields?.first?.text, let _ = Int32(roomId) else {
                self.showAlert(for: nil, orMessage: "请输入数字")
                return
            }

            var joinRoomRequest = Werewolf_JoinRoomRequest()
            joinRoomRequest.roomID = roomId
            _ = try? self.gameSrvClient.joinRoom(joinRoomRequest) { joinRoomResponse, callResult in

                guard let userID = joinRoomResponse?.userID else {
                    self.showAlert(for: callResult)
                    return
                }

                let roomController: RoomViewController = RoomViewController(roomID: roomId, userID: userID, client: self.gameSrvClient)
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(roomController, animated: true)
                }
            }
        }))

        self.present(joinRoomAlert, animated: true, completion: nil)
    }

}

