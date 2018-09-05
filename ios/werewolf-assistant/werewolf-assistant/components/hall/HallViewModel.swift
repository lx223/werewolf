//
//  HallViewModel.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 02/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SwiftGRPC
import RxCocoa

protocol HallViewModeling {
    func drive(controller: ViewController)
    func dispose()
}

final class HallViewModel: HallViewModeling {

    let gameManager: GameManaging = GameManager()

    let gameSrvClient: Werewolf_GameServiceService

    private var disposeBag = DisposeBag()
    private var joinRoomAlertController = JoinRoomAlertController()

    init() {
        gameSrvClient = Werewolf_GameServiceServiceClient(address: Constants.serverAddress, secure: false, arguments: [])
        // swiftlint:disable:next force_try
        try! gameSrvClient.metadata.add(key: "x-api-key", value: Constants.googleAPIKey)
    }

    func dispose() {
        disposeBag = DisposeBag()
    }

    func drive(controller: ViewController) {
        controller.navigationItem.title = R.string.localizable.hallSceneTitle()

        controller.createRoomBtn.rx.tap
            .flatMapLatest({_ -> Observable<Werewolf_CreateAndJoinRoomResponse> in
                let req = Werewolf_CreateAndJoinRoomRequest()
                return self.gameSrvClient.createAndJoinRoomRx(req)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (res) in
                let roomID = res.roomID, userID = res.userID
                self.gameManager.roomID.accept(roomID)
                self.gameManager.userID.accept(userID)

                let configController = ConfigurationViewController(roomID: roomID, userID: userID, client: self.gameSrvClient)
                controller.navigationController?.pushViewController(configController, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        controller.joinRoomBtn.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (_) in
                controller.present(self.joinRoomAlertController, animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        joinRoomAlertController.onConfirmHandler = { (roomID) in
            var req = Werewolf_JoinRoomRequest()
            req.roomID = roomID
            self.gameSrvClient.joinRoomRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (res) in
                    let userID = res.userID

                    self.gameManager.userID.accept(userID)
                    self.gameManager.roomID.accept(roomID)

                    let roomViewModel = RoomViewModel(roomID: roomID, userID: userID, client: self.gameSrvClient)
                    let roomController = RoomViewController(viewModel: roomViewModel)
                    controller.navigationController?.pushViewController(roomController, animated: true)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: self.disposeBag)
        }

        Observable
            .combineLatest(gameManager.roomID.asObservable(), gameManager.userID.asObservable())
            .flatMapLatest { (roomID, userID) -> Observable<Bool> in
                return Observable.just(userID != nil && roomID != nil)
            }
            .bind(to: controller.joinLastRoomBtn.rx.isEnabled)
            .disposed(by: disposeBag)

        controller.joinLastRoomBtn.rx.tap
            .flatMapLatest { (_) -> Observable<(String?, String?)> in
                return Observable
                    .combineLatest(
                        self.gameManager.roomID.asObservable(),
                        self.gameManager.userID.asObservable()
                    )
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (pair) in
                guard let roomID = pair.0, let userID = pair.1 else {
                    return
                }
                let roomViewModel = RoomViewModel(roomID: roomID, userID: userID, client: self.gameSrvClient)
                let roomController = RoomViewController(viewModel: roomViewModel)
                controller.navigationController?.pushViewController(roomController, animated: true)
            }, onError: { (_) in
                self.gameManager.roomID.accept(nil)
                self.gameManager.userID.accept(nil)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
