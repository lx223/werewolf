//
//  UIViewExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func attachRecogniser(numOfTap taps: Int, forTarget target: Any?, withAction action: Selector?) {
        let rec = UITapGestureRecognizer(target: target, action: action)
        rec.numberOfTapsRequired = taps
        addGestureRecognizer(rec)
    }
}
