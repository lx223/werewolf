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
    @IBOutlet weak var roleImageView: UIImageView!

    private var _seatTaken: Int?
    fileprivate var seatTaken: Int? {
        get {
            return _seatTaken
        }
        set {
            _seatTaken = newValue
            roleImageView.isHidden = newValue == nil
        }
    }

    fileprivate let gameSrvClient: Werewolf_GameServiceService
    private let userID: String
    private let roomID: Int32
    private let room: Werewolf_Room

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

        roleImageView.attachRecogniser(numOfTap: 1, forTarget: self, withAction: #selector(onRoleImageViewPressed))
        roleImageView.isUserInteractionEnabled = true
    }

    init(roomID: Int32, userID: String, client: Werewolf_GameServiceService, room: Werewolf_Room = Werewolf_Room()) {
        self.roomID = roomID
        self.userID = userID
        self.room = room
        self.gameSrvClient = client

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoomViewController {
    @objc func onRoleImageViewPressed(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIImageView, let seat = seatTaken else {
            return
        }

        let role = room.seats[seat - 1].role
        view.image = UIImage.image(forRole: role)
    }

    @IBAction func onStartGameButtonPressed(_ btn: UIBarButtonItem) {
        var req = Werewolf_StartGameRequest()
        req.userID = userID
        req.roomID = roomID
        _ = try? gameSrvClient.startGame(req) { (res, callResult) in
            guard let _ = res else {
                self.showAlert(for: callResult)
                return
            }

            self.showAlert(for: nil, orMessage: "game started")
        }
    }

    @IBAction func onLastNightButtonPressed(_ btn: UIBarButtonItem) {
        var req = Werewolf_GetFirstDayResultRequest()
        req.userID = userID
        req.roomID = roomID
        _ = try? gameSrvClient.getFirstDayResult(req) { (res, callResult) in
            guard let nums = res?.deadPlayerNumbers else {
                self.showAlert(for: callResult)
                return
            }

            self.showAlert(for: nil, orMessage: "First night: \(nums)")
        }
    }

    @IBAction func onUseSkillButtonPressed(_ btn: UIBarButtonItem) {
        print("use skill")
    }

    @objc func onSeatPressed(_ sender: UITapGestureRecognizer) {
        guard let seatView = sender.view as? SeatView else {
            return
        }

        var req = Werewolf_TakeSeatRequest()
        req.seatID = room.seats[seatView.number - 1].id
        req.userID = userID
        req.roomID = roomID

        _ = try? gameSrvClient.takeSeat(req) { (res, callResult) in
            guard let _ = res else {
                self.showAlert(for: callResult)
                return
            }

            self.showAlert(for: nil, orMessage: "Took seat \(seatView.number)")
            self.seatTaken = seatView.number
        }
    }
}
