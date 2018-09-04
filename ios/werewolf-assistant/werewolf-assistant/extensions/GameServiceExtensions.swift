//
//  GameServiceExtensions.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 19/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import RxSwift
import SwiftGRPC

extension Werewolf_GameServiceService {
    func vacateSeatRx(_ req: Werewolf_VacateSeatRequest) -> Observable<Werewolf_VacateSeatResponse> {
        return rxUnary(req, self.vacateSeat)
    }

    func reassignRolesRx(_ req: Werewolf_ReassignRolesRequest) -> Observable<Werewolf_ReassignRolesResponse> {
        return rxUnary(req, self.reassignRoles)
    }

    func startGameRx(_ req: Werewolf_StartGameRequest) -> Observable<Werewolf_StartGameResponse> {
        return rxUnary(req, self.startGame)
    }

    func getRoomRx(_ req: Werewolf_GetRoomRequest) -> Observable<Werewolf_GetRoomResponse> {
        return rxUnary(req, self.getRoom)
    }

    func takeActionRx(_ req: Werewolf_TakeActionRequest) -> Observable<Werewolf_TakeActionResponse> {
        return rxUnary(req, self.takeAction)
    }

    func takeSeatRx(_ req: Werewolf_TakeSeatRequest) -> Observable<Werewolf_TakeSeatResponse> {
        return rxUnary(req, self.takeSeat)
    }

    func createAndJoinRoomRx(_ req: Werewolf_CreateAndJoinRoomRequest) -> Observable<Werewolf_CreateAndJoinRoomResponse> {
        return rxUnary(req, self.createAndJoinRoom)
    }

    func joinRoomRx(_ req: Werewolf_JoinRoomRequest) -> Observable<Werewolf_JoinRoomResponse> {
        return rxUnary(req, self.joinRoom)
    }

    private func rxUnary<T, K>(_ req: T, _ asyncRPC: @escaping (_ request: T, _ completion: @escaping (K?, CallResult) -> Void) throws -> ClientCallUnary) -> Observable<K> {
        return Observable<K>.create { observer -> Disposable in
            let call = try? asyncRPC(req) {
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
