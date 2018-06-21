//
//  SoundQueue.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 21/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import SwiftySound

protocol SoundQueuing {
    func queue(_ sound: Sound)
}

final class SoundQueuer: SoundQueuing {

    private var queue = [Sound]()

    func queue(_ sound: Sound) {
        if queue.isEmpty {
            queue.append(sound)
            self.playNext()
        } else {
            queue.append(sound)
        }
    }

    private func playNext() {
        guard !queue.isEmpty else {
            return
        }

        let s = queue.first
        s?.play { _ in
            self.queue.removeFirst()
            self.playNext()
        }
    }
}
