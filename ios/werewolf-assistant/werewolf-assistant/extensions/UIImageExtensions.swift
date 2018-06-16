//
//  UIImageExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func image(forRole role: Werewolf_Role) -> UIImage? {
        switch role {
        case .seer:
            return UIImage(named: "预言家")
        case .villager:
            return UIImage(named: "村民")
        case .witch:
            return UIImage(named: "女巫")
        case .hunter:
            return UIImage(named: "猎人")
        case .idiot:
            return UIImage(named: "白痴")
        case .guardian:
            return UIImage(named: "守卫")
        case .werewolf:
            return UIImage(named: "狼人")
        case .whiteWerewolf:
            return UIImage(named: "白狼王")
        case .orphan:
            return UIImage(named: "")
        case .halfBlood:
            return UIImage(named: "混血儿")
        default:
            return nil
        }
    }
}
