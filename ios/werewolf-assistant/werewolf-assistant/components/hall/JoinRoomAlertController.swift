//
//  JoinRoomAlertController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 02/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import UIKit

final class JoinRoomAlertController: UIAlertController {

    var onConfirmHandler: ((_ roomID: String) -> Void)?

    override var message: String? {
        set {}
        get {
            return R.string.localizable.joinRoomAlertMsg()
        }
    }

    override var preferredStyle: UIAlertControllerStyle {
        return .alert
    }

    private weak var roomNumberTextField: UITextField?

    init() {
        super.init(nibName: nil, bundle: nil)

        addTextField { (textField) in
            self.roomNumberTextField = textField

            textField.placeholder = R.string.localizable.joinRoomAlertPlaceholder()
            textField.keyboardType = .numberPad
        }
        addAction(UIAlertAction(title: R.string.localizable.joinRoomAlertCancel(), style: .cancel, handler: nil))
        addAction(UIAlertAction(title: R.string.localizable.joinRoomAlertConfirm(), style: .default, handler: {  (_) in
            if let roomID = self.roomNumberTextField?.text, let _ = Int32(roomID) {
                self.onConfirmHandler?(roomID)
            }
        }))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
