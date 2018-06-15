//
//  SeatView.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit

@IBDesignable
class SeatView: UIView {

    @IBInspectable var number: Int = 0

    private let cornerRadius: CGFloat = 3

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.cornerRadius = cornerRadius
    }
}
