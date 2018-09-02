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
    func subscribe()
}

final class HallViewModel: HallViewModeling {

    let gameSrvClient: Werewolf_GameServiceService

    private weak var controller: ViewController?
    private let disposeBag = DisposeBag()
    private lazy var joinRoomAlertController: UIAlertController = {
        return JoinRoomAlertController(onConfirm: { (roomID) in
            var req = Werewolf_JoinRoomRequest()
            req.roomID = roomID
            self.gameSrvClient.joinRoomRx(req)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (res) in
                let roomController: RoomViewController = RoomViewController(roomID: roomID, userID: res.userID, client: self.gameSrvClient)
                self.controller?.navigationController?.pushViewController(roomController, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: self.disposeBag)
        }, onCancel: nil)
    }()

    init(controller: ViewController) {
        self.controller = controller

        gameSrvClient = Werewolf_GameServiceServiceClient(address:Constants.serverAddress, secure: false, arguments: [])
        try! gameSrvClient.metadata.add(key: "x-api-key", value: Constants.googleAPIKey)
    }

    func subscribe() {
        self.controller?.createRoomBtn.rx.tap
            .flatMapLatest({_ -> Observable<Werewolf_CreateAndJoinRoomResponse> in
                let req = Werewolf_CreateAndJoinRoomRequest()
                return self.gameSrvClient.createAndJoinRoomRx(req)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (res) in
                let configController = ConfigurationViewController(roomID: res.roomID, userID: res.userID, client: self.gameSrvClient)
                self.controller?.navigationController?.pushViewController(configController, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        self.controller?.joinRoomBtn.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (_) in
                self.controller?.present(self.joinRoomAlertController, animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
