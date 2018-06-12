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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCreateRoomButtonPressed(_ sender: UIButton) {
        do {
            let createRoomResponse = try roomSrvClient.createRoom(Room_CreateRoomRequest())
            print(createRoomResponse.roomID)
        } catch RPCError.callError(let callResult) {
            print(callResult)
        } catch {
            print("unknown issue")
        }
    }

    @IBAction func onJoinRoomButtonPressed(_ sender: UIButton) {
    }


}

