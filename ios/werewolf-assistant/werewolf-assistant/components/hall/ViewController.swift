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

final class ViewController: UIViewController {

    @IBOutlet weak var createRoomBtn: UIButton!
    @IBOutlet weak var joinRoomBtn: UIButton!
    @IBOutlet weak var joinLastRoomBtn: UIButton!

    var viewModel: HallViewModeling? = HallViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.drive(controller: self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel?.dispose()
    }

}

