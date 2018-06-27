//
//  CollectionExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 27/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
