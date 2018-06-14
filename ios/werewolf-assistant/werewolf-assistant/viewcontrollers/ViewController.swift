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

    private var roomSrvClient: Room_RoomServiceService = Room_RoomServiceServiceClient(address:"localhost:8080", secure: false, arguments: [])
    private var roomId: Int32 = 0
    private var userId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCreateRoomButtonPressed(_ sender: UIButton) {
        _ = try? roomSrvClient.createRoom(Room_CreateRoomRequest()){ createRoomResponse, callResult in
            guard let roomID = createRoomResponse?.roomID else {
                print(callResult)
                return
            }

            let configController = ConfigurationViewController(roomID: roomID)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(configController, animated: true)
            }
        }
    }

    @IBAction func onJoinRoomButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "请输入房间号", preferredStyle: .alert)

        alert.addTextField(configurationHandler: nil)

        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak alert] (_) in
            guard let text = alert?.textFields?.first?.text,
                let roomId = Int32(text) else {
                return
            }

            var joinRoomRequest = Room_JoinRoomRequest()
            joinRoomRequest.roomID = roomId
            _ = try? self.roomSrvClient.joinRoom(joinRoomRequest) { createRoomResponse, callResult in
                if let userID = createRoomResponse?.userID {
                    let roomController: RoomViewController = RoomViewController(roomID: roomId, userID: userID)

                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(roomController, animated: true)
                    }
                } else {
                    print(callResult)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

