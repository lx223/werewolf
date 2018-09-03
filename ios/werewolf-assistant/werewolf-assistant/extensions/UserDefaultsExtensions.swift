//
//  UserDefaultsExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 03/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation

fileprivate let roomIDKey = "room_id_key"
fileprivate let userIDKey = "user_id_key"

extension UserDefaults {
    static var roomID: String? {
        get {
            return UserDefaults.standard.string(forKey: roomIDKey)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: roomIDKey)
        }
    }

    static var userID: String? {
        get {
            return UserDefaults.standard.string(forKey: userIDKey)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: userIDKey)
        }
    }
}
