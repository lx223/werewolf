//
//  GameServiceExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 19/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import RxSwift

extension Werewolf_GameServiceService {
    func takeActionRx(_ req: Werewolf_TakeActionRequest) -> Observable<Werewolf_TakeActionResponse> {
        return Observable<Werewolf_TakeActionResponse>.create { observer -> Disposable in
            let call = try? self.takeAction(req) {
                guard let res = $0 else {
                    observer.onError($1)
                    return
                }

                observer.onNext(res)
                observer.onCompleted()
            }

            return Disposables.create {
                call?.cancel()
            }
        }
    }
}
