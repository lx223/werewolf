//
//  RoomViewModel.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 03/09/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftGRPC
import MaterialComponents
import SwiftySound
import Floaty

@objc protocol RoomViewModeling {
    func drive(controller: RoomViewController)
    func dispose()

    @objc func onRoleImageViewPressed(_ sender: UITapGestureRecognizer)
}

final class RoomViewModel: RoomViewModeling {

    enum SeatTapActionType {
        case takeSeat, vacateSeat, witchPoison
    }

    private var seatTapActionType: SeatTapActionType = .takeSeat

    private var disposeBag = DisposeBag()

    private let gameServiceClient: Werewolf_GameServiceService
    private let userID: String
    private let roomID: String
    private let isHost: Bool

    private let soundQueuer: SoundQueuing = SoundQueuer()
    private let game = BehaviorRelay<Werewolf_Game?>(value: nil)
    private let seats = BehaviorRelay<[Werewolf_Seat]?>(value: nil)
    private let seatTaken = BehaviorRelay<Werewolf_Seat?>(value: nil)
    private let showingRole = BehaviorRelay<Bool>(value: false)

    func dispose() {
        disposeBag = DisposeBag()
    }

    init(roomID: String, userID: String, client: Werewolf_GameServiceService, isHost: Bool = false) {
        self.roomID = roomID
        self.userID = userID
        self.gameServiceClient = client
        self.isHost = isHost

        var req = Werewolf_GetRoomRequest()
        req.roomID = self.roomID
        Observable<Int>
            .timer(RxTimeInterval(0), period: RxTimeInterval(0.5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { _ -> Observable<Werewolf_GetRoomResponse> in
                return self.gameServiceClient.getRoomRx(req)
            }
            .flatMapLatest({ (res) -> Observable<Werewolf_Room> in
                Observable.just(res.room)
            })
            .distinctUntilChanged()
            .subscribe(onNext: { (room) in
                if room.hasGame {
                    self.game.accept(room.game)
                }
                self.seats.accept(room.seats)

            }, onError: nil)
            .disposed(by: disposeBag)

        seats
            .distinctUntilChanged()
            .subscribe(onNext: { (seats) in
                if let seat = seats?.first(where: { $0.user.id == self.userID }) {
                    self.seatTaken.accept(seat)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        game
            .asObservable()
            .flatMapLatest {
                Observable.just($0?.state)
            }
            .distinctUntilChanged()
            .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "sound stream"))
            .scan(nil, accumulator: { (previous, current) -> Werewolf_Game.State? in
                if let s = previous, let sound = Sound.getClosingSound(forState: s), self.isHost  {
                    self.soundQueuer.queue(sound)
                }

                return current
            })
            .subscribe(onNext: { (state) in
                guard let s = state, let sound = Sound.getOpeningSound(forState: s), self.isHost else {
                    return
                }

                self.soundQueuer.queue(sound)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func drive(controller: RoomViewController) {
        controller.roomNumberLabel.text = R.string.localizable.roomLabelTemplate(roomID)
        configureFloatingActions(controller)
        driveSeatsVisibility(controller)
        driveSeatButtonPressed(controller)
        driveRoleImageVisibility(controller)
    }
}

extension RoomViewModel {
    func driveSeatsVisibility(_ controller: RoomViewController) {
        seats
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (seatsOption) in
                guard let seats = seatsOption, let seatBtns = controller.seatButtons else {
                    return
                }

                for i in 0..<seats.count {
                    seatBtns[i].alpha = 1.0
                    seatBtns[i].backgroundColor = seats[i].hasUser ? .seatTaken : .seatVacant;
                }

                for i in seats.count..<seatBtns.count {
                    seatBtns[i].alpha = 0.0
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func driveRoleImageVisibility(_ controller: RoomViewController) {
        seatTaken
            .distinctUntilChanged()
            .flatMapLatest({ (seat) -> Observable<Bool> in
                return Observable.just(seat == nil)
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (hasNotTakenSeat) in
                controller.roleImageView.isHidden = hasNotTakenSeat
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        let roleImageStream = seatTaken
            .distinctUntilChanged()
            .flatMapLatest { (seat) -> Observable<UIImage?> in
                guard let role = seat?.role else {
                    return Observable.just(nil)
                }

                return Observable.just(UIImage.image(forRole: role))
            }

        Observable
            .combineLatest(roleImageStream, showingRole.asObservable()) { (role, showing) -> UIImage? in
                return showing ? role : #imageLiteral(resourceName: "卡背")
            }
            .bind(to: controller.roleImageView.rx.image)
            .disposed(by: disposeBag)
    }

    func driveSeatButtonPressed(_ controller: RoomViewController) {
        Observable
            .merge(controller.seatButtons
                .compactMap { (button) -> Observable<MDCButton> in
                    return button.rx.tap.flatMapLatest({ (_) -> Observable<MDCButton> in
                        return Observable.just(button)
                    })
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (button) in
                switch self.seatTapActionType {
                case .vacateSeat:
                    self.handleVacateSeatTap(on: button)
                case .witchPoison:
                    self.handleWitchPoisonSeatTap(on: button, controller)
                default:
                    self.tryHandleRoleSkill(button, controller)
                    self.tryHandleSeatTaking(button, controller)
                }
                self.seatTapActionType = .takeSeat
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func handleVacateSeatTap(on seatBtn: MDCButton) {
        guard let seatID = seats.value?[seatBtn.number - 1].id, seatTapActionType == .vacateSeat else {
            return
        }

        var req = Werewolf_VacateSeatRequest()
        req.seatID = seatID
        gameServiceClient.vacateSeatRx(req)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: nil, onError: { (err) in
                print(err)
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func handleWitchPoisonSeatTap(on seatBtn: MDCButton, _ controller: RoomViewController) {
        guard let seatID = seats.value?[seatBtn.number - 1].id,
            let gameID = self.game.value?.id,
            seatTapActionType == .witchPoison else {
            return
        }

        var req = Werewolf_TakeActionRequest()
        req.witch.poisonSeatID = seatID
        req.gameID = gameID
        self.gameServiceClient
            .takeActionRx(req)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (res) in
                controller.showSnackbar(withMessage: R.string.localizable.witchActionPoisonSuccess())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

extension RoomViewModel {
    func tryHandleRoleSkill(_ seatButton: MDCButton, _ controller: RoomViewController) {
        guard let gameState = game.value?.state, let role = seatTaken.value?.role, let seatID = seats.value?[seatButton.number - 1].id, let gameID = game.value?.id else {
            return
        }

        var req = Werewolf_TakeActionRequest()
        req.gameID = gameID
        switch gameState {
        case .seerAwake:
            if role != .seer {
                return
            }
            req.seer.seatID = seatID
            gameServiceClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (res) in
                    let msg = (res.seer.ruling == .positive) ? R.string.localizable.seerActionRulingPositive() : R.string.localizable.seerActionRulingNegative()
                    controller.showSnackbar(withMessage: "\(msg)")
                })
                .disposed(by: disposeBag)
        case .halfBloodAwake:
            if role != .halfBlood {
                return
            }
            req.halfBlood.seatID = seatID
            gameServiceClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (_) in
                    controller.showSnackbar(withMessage: "榜样设立成功")
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        case .guardianAwake:
            if role != .guardian {
                return
            }
            req.guard.seatID = seatID
            gameServiceClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (_) in
                    controller.showSnackbar(withMessage: "守卫成功")
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        case .werewolfAwake:
            if role != .werewolf && role != .whiteWerewolf {
                return
            }
            req.werewolf.seatID = seatID
            gameServiceClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (_) in
                    controller.showSnackbar(withMessage: R.string.localizable.wolfKillSuccess())
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        default:
            break
        }
    }

    func tryHandleSeatTaking(_ seatButton: MDCButton, _ controller: RoomViewController) {
        guard let seatID = seats.value?[seatButton.number - 1].id,
            let hasUser = seats.value?[seatButton.number - 1].hasUser,
            !hasUser else {
                return
        }

        var req = Werewolf_TakeSeatRequest()
        req.seatID = seatID
        req.userID = userID

        gameServiceClient
            .takeSeatRx(req)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                controller.showSnackbar(withMessage: R.string.localizable.takeSeatSuccessTemplate(seatButton.number))
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

extension RoomViewModel {
    func configureFloatingActions(_ controller: RoomViewController) {
        controller.floatingBtn.addItem(item: startGameFloatyItem(controller))
        controller.floatingBtn.addItem(item: assignRolesFloatyItem(controller))
        controller.floatingBtn.addItem(item: lastNightInfoFloatyItem(controller))
        controller.floatingBtn.addItem(item: useSkillFloatyItem(controller))
        controller.floatingBtn.addItem(item: vacateSeatFloatyItem(controller))

        controller.floatingBtn.items.reverse()
    }

    func vacateSeatFloatyItem(_ controller: RoomViewController) -> FloatyItem {
        let item = FloatyItem()
        item.title = R.string.localizable.vacateSeatBtnTitle()
        item.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                self.seatTapActionType = .vacateSeat
                controller.showSnackbar(withMessage: R.string.localizable.vacateSeatSnackbarMessage())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        return item
    }

    func startGameFloatyItem(_ controller: RoomViewController) -> FloatyItem {
        let item = FloatyItem()
        item.title = R.string.localizable.startGameBtnTitle()
        item.rx.tap.flatMapLatest { (_) -> Observable<Werewolf_StartGameResponse> in
                var req = Werewolf_StartGameRequest()
                req.roomID = self.roomID
                return self.gameServiceClient.startGameRx(req)
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                controller.showSnackbar(withMessage: R.string.localizable.gameStartedSnackMessage())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        return item
    }

    func assignRolesFloatyItem(_ controller: RoomViewController) -> FloatyItem {
        let item = FloatyItem()
        item.title = R.string.localizable.assignRolesBtnTitle()
        item.rx.tap
            .flatMapLatest { (_) -> Observable<Werewolf_ReassignRolesResponse> in
                var req = Werewolf_ReassignRolesRequest()
                req.roomID = self.roomID
                return self.gameServiceClient.reassignRolesRx(req)
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                controller.showAlert(for: nil, orMessage: R.string.localizable.reassignRoleSuccess())
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        return item
    }

    func lastNightInfoFloatyItem(_ controller: RoomViewController) -> FloatyItem {
        let item = FloatyItem()
        item.title = R.string.localizable.lastNightInfoBtnTitle()
        item.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                let killedSeatIndices = self.game.value?.killedSeatIds.compactMap({ (seatID) -> String? in
                    guard let i = self.seats.value?.index(where: { $0.id == seatID }) else {
                        return nil
                    }
                    return String(i + 1)
                })
                guard let killedSeatString = killedSeatIndices?.joined(separator: ",") else {
                    return
                }

                let msg = killedSeatString.isEmpty ? R.string.localizable.peacefulNightSnackMessage() : R.string.localizable.killedPlayersMessageTemplate(killedSeatString)
                controller.showAlert(for: nil, orMessage: msg)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        return item
    }

    func useSkillFloatyItem(_ controller: RoomViewController) -> FloatyItem {
        let item = FloatyItem()
        item.title = R.string.localizable.useSkillBtnTitle()
        item.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                self.onUseSkillButtonPressed(controller)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        return item
    }

    func onUseSkillButtonPressed(_ controller: RoomViewController) {
        guard let role = self.seatTaken.value?.role, let gameID = self.game.value?.id else {
            return
        }

        var req = Werewolf_TakeActionRequest()
        req.gameID = gameID
        switch role {
        case .seer,
             .guardian,
             .werewolf,
             .halfBlood:
            controller.showSnackbar(withMessage: R.string.localizable.chooseTargetSnackMessage())
        case .hunter:
            req.hunter = Werewolf_TakeActionRequest.HunterAction()
            self.gameServiceClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (res) in
                    let msg = (res.seer.ruling == .positive) ? R.string.localizable.hunterActionRulingPositive() : R.string.localizable.hunterActionRulingNegative()
                    controller.showSnackbar(withMessage: "\(msg)")
                })
                .disposed(by: self.disposeBag)
        case .witch:
            let killedSeatID = self.game.value?.killedSeatIds.first
            let killedSeatNumber = self.seats.value?.index(where: { (seat) -> Bool in
                seat.id == killedSeatID
            })

            let alert = WitchActionAlertController(killedSeatNumber: killedSeatNumber)
            alert.onCureBtnPressed = {
                guard let seatID = killedSeatID, let gameID = self.game.value?.id else {
                    return
                }

                var req = Werewolf_TakeActionRequest()
                req.witch.cureSeatID = seatID
                req.gameID = gameID
                self.gameServiceClient
                    .takeActionRx(req)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { (res) in
                        controller.showSnackbar(withMessage: R.string.localizable.witchActionSaveSuccess())
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .disposed(by: self.disposeBag)
            }
            alert.onPoisonBtnPressed = {
                self.seatTapActionType = .witchPoison
                controller.showSnackbar(withMessage: R.string.localizable.witchActionPoisonSnackbarMsg())
            }
            alert.onNoActionBtnPressed = {
                guard let gameID = self.game.value?.id else {
                    return
                }

                var req = Werewolf_TakeActionRequest()
                req.gameID = gameID
                self.gameServiceClient
                    .takeActionRx(req)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { (res) in
                        controller.showSnackbar(withMessage: R.string.localizable.witchNoActionSuccess())
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .disposed(by: self.disposeBag)
            }
            controller.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }

    @objc func onRoleImageViewPressed(_ sender: UITapGestureRecognizer) {
        self.showingRole.accept(!self.showingRole.value)
    }
}

