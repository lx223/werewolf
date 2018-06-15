//
//  RoomViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 14/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {

    private var userID: String
    private var roomID: Int32
    
    private var roomTitle: String {
        return "房间: \(self.roomID)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.roomTitle
        self.navigationItem.hidesBackButton = true
    }

    init(roomID: Int32, userID: String) {
        self.roomID = roomID
        self.userID = userID

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
