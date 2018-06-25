//
//  MDCButtonExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 25/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import MaterialComponents

extension MDCButton {
    var number: Int {
        guard let t = titleLabel?.text, let n = Int(t) else {
            fatalError("invalid seat button")
        }
        return n
    }
}
