//
//  SoundExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 21/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import SwiftySound

extension Sound {
    static var darkness: Sound = {
        return Sound.sound(forFile: "天黑了")!
    }()

    static var witchOpening: Sound = {
        return Sound.sound(forFile: "女巫睁眼")!
    }()

    static var witchClosing: Sound = {
        return Sound.sound(forFile: "女巫闭眼")!
    }()

    static var guardOpening: Sound = {
        return Sound.sound(forFile: "守卫睁眼")!
    }()

    static var guardClosing: Sound = {
        return Sound.sound(forFile: "守卫闭眼")!
    }()

    static var halfBloodOpening: Sound = {
        return Sound.sound(forFile: "混子睁眼")!
    }()

    static var halfBloodClosing: Sound = {
        return Sound.sound(forFile: "混子闭眼")!
    }()

    static var werewolfOpening: Sound = {
        return Sound.sound(forFile: "狼人睁眼")!
    }()

    static var werewolfClosing: Sound = {
        return Sound.sound(forFile: "狼人闭眼")!
    }()

    static var hunterOpening: Sound = {
        return Sound.sound(forFile: "猎人睁眼")!
    }()

    static var hunterClosing: Sound = {
        return Sound.sound(forFile: "猎人闭眼")!
    }()

    static var sheriffElection: Sound = {
        return Sound.sound(forFile: "警长竞选")!
    }()

    static var orphanOpening: Sound = {
        return Sound.sound(forFile: "野孩子睁眼")!
    }()

    static var orphanClosing: Sound = {
        return Sound.sound(forFile: "野孩子闭眼")!
    }()

    static var seerOpening: Sound = {
        return Sound.sound(forFile: "预言家睁眼")!
    }()

    static var seerClosing: Sound = {
        return Sound.sound(forFile: "预言家闭眼")!
    }()

    class func sound(forFile file: String, withExtension ext: String = "m4a") -> Sound? {
        if let url = Bundle.main.url(forResource: file, withExtension: ext) {
            return Sound(url: url)
        }
        return nil
    }

    class func getClosingSound(forState state: Werewolf_Game.State) -> Sound? {
        var sound: Sound?
        switch state {
        case .unknown:
            sound = Sound.darkness
        case .orphanAwake:
            sound = Sound.orphanClosing
        case .halfBloodAwake:
            sound = Sound.halfBloodClosing
        case .guardianAwake:
            sound = Sound.guardClosing
        case .werewolfAwake:
            sound = Sound.werewolfClosing
        case .witchAwake:
            sound = Sound.witchClosing
        case .seerAwake:
            sound = Sound.seerClosing
        case .hunterAwake:
             sound = Sound.hunterClosing
        default:
            sound = nil
        }
        return sound
    }

    class func getOpeningSound(forState state: Werewolf_Game.State) -> Sound? {
        switch state {
        case .orphanAwake:
            return Sound.orphanOpening
        case .halfBloodAwake:
            return Sound.halfBloodOpening
        case .guardianAwake:
            return Sound.guardOpening
        case .werewolfAwake:
            return Sound.werewolfOpening
        case .witchAwake:
            return Sound.witchOpening
        case .seerAwake:
            return Sound.seerOpening
        case .hunterAwake:
            return Sound.hunterOpening
        case .sheriffElection:
            return sheriffElection
        default:
           return nil
        }
    }
}
