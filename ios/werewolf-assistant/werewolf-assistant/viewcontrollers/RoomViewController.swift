//
//  RoomViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {

    @IBOutlet var seats: [SeatView]!
    
    private var userID: String
    private var roomID: Int32
    private var room: Werewolf_Room

    private var roomTitle: String {
        return "房间: \(self.roomID)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.roomTitle

        seats.sort { $0.number < $1.number }
        for i in room.seats.count..<seats.count {
            seats[i].alpha = 0.0
        }

        for i in 0..<room.seats.count {
            seats[i].attachRecogniser(numOfTap: 1, forTarget: self, withAction: #selector(onSeatPressed))
        }
    }

    init(roomID: Int32, userID: String, room: Werewolf_Room = Werewolf_Room()) {
        self.roomID = roomID
        self.userID = userID
        self.room = room

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoomViewController {
    @IBAction func onRevealIdentityButtonPressed(_ btn: UIBarButtonItem) {
        print("real identity")
    }

    @IBAction func onStartGameButtonPressed(_ btn: UIBarButtonItem) {
        print("start game")
    }

    @IBAction func onLastNightButtonPressed(_ btn: UIBarButtonItem) {
        print("last night")
    }

    @IBAction func onUseSkillButtonPressed(_ btn: UIBarButtonItem) {
        print("use skill")
    }

    @IBAction func onSeatPressed(_ sender: UITapGestureRecognizer) {
        guard let seatView = sender.view as? SeatView else {
            return
        }

        print(seatView.number)
    }
}
