//
//  GameManager.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 03/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol GameManaging {
    var roomID: BehaviorRelay<String?> { get }
    var userID: BehaviorRelay<String?> { get }
}

final class GameManager: GameManaging {
    var roomID = BehaviorRelay<String?>(value: UserDefaults.roomID)
    var userID = BehaviorRelay<String?>(value: UserDefaults.userID)

    private let disposeBag = DisposeBag()

    init() {
        roomID
            .distinctUntilChanged()
            .subscribe(onNext: { (roomID) in
                UserDefaults.roomID = roomID
            })
            .disposed(by: disposeBag)

        userID
            .distinctUntilChanged()
            .subscribe(onNext: { (userID) in
                UserDefaults.userID = userID
            })
            .disposed(by: disposeBag)
    }
}
