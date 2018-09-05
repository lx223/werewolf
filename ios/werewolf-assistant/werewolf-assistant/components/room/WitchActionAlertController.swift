//
//  WitchActionAlertController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 05/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import UIKit

final class WitchActionAlertController: UIAlertController {
    var onCureBtnPressed: (() -> Void)?
    var onPoisonBtnPressed: (() -> Void)?
    var onNoActionBtnPressed: (() -> Void)?

    override var preferredStyle: UIAlertControllerStyle {
        return .alert
    }

    init(killedSeatNumber: Int?) {
        super.init(nibName: nil, bundle: nil)

        title = R.string.localizable.witchActionTitle()
        message = killedSeatNumber != nil ? R.string.localizable.witchActionKilledTemplate(killedSeatNumber!) : R.string.localizable.witchActionNoDeath()

        if killedSeatNumber != nil {
            addAction(UIAlertAction(title: R.string.localizable.witchActionSave(), style: .default, handler: {(_) in
                self.onCureBtnPressed?()
            }))
        }
        addAction(UIAlertAction(title: R.string.localizable.witchActionPoison(), style: .destructive, handler: {  (_) in
            self.onPoisonBtnPressed?()
        }))
        addAction(UIAlertAction(title: R.string.localizable.witchNoAction(), style: .cancel, handler: { _ in
            self.onNoActionBtnPressed?()
        }))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
