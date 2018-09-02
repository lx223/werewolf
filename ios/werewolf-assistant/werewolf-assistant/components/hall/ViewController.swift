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

    var viewModel: HallViewModeling?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = HallViewModel(controller: self)
        viewModel?.subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationItem.title = R.string.localizable.hallSceneTitle()
    }

}

