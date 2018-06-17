//
//  WerewolfRoleExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 17/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation

extension Werewolf_Role {
    static var allCases: [Werewolf_Role] {
        return [
            .villager,
            .seer,
            .witch,
            .hunter,
            .idiot,
            .guardian,
            .werewolf,
            .whiteWerewolf,
            .orphan,
            .halfBlood
        ]
    }
}
