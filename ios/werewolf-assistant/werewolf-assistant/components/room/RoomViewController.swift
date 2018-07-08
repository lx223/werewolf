//
//  RoomViewController.swift
//  werewolf-assistant
//
//  Created by Lan Xiao on 15/06/2018.
//  Copyright © 2018 Lan Xiao. All rights reserved.
//

import UIKit
import RxSwift
import SwiftGRPC
import RxCocoa
import SwiftySound
import MaterialComponents

class RoomViewController: UIViewController {

    @IBOutlet var seatButtons: [MDCButton]!
    @IBOutlet weak var roleImageView: UIImageView!

    private var seatTaken: Werewolf_Seat?

    private var disposeBag = DisposeBag()

    private let gameSrvClient: Werewolf_GameServiceService
    private let userID: String
    private let roomID: String
    private let isHost: Bool

    private let soundQueuer: SoundQueuing = SoundQueuer()
    private let game = BehaviorRelay<Werewolf_Game?>(value: nil)
    private let seats = BehaviorRelay<[Werewolf_Seat]?>(value: nil)
    private let showingRole = BehaviorRelay<Bool>(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        let roomLabel = UILabel()
        roomLabel.text = R.string.localizable.roomLabelTemplate(roomID)
        let rightBarButtonItem = UIBarButtonItem(customView: roomLabel)
        navigationItem.setRightBarButton(rightBarButtonItem, animated: false)

        roleImageView.attachRecogniser(numOfTap: 1, forTarget: self, withAction: #selector(onRoleImageViewPressed))

        initGetRoomStream()
        configureSeatsSubscription()
        configureGameSubscription()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        disposeBag = DisposeBag()
    }

    init(roomID: String, userID: String, client: Werewolf_GameServiceService, isHost: Bool = false) {
        self.roomID = roomID
        self.userID = userID
        self.gameSrvClient = client
        self.isHost = isHost

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoomViewController {
    @objc func onRoleImageViewPressed(_ sender: UITapGestureRecognizer) {
        showingRole.accept(!showingRole.value)
    }

    @IBAction func onStartGameButtonPressed(_ btn: UIBarButtonItem) {
        var req = Werewolf_StartGameRequest()
        req.roomID = roomID
        _ = try? gameSrvClient.startGame(req) { (res, callResult) in
            guard let _ = res else {
                self.showAlert(for: callResult)
                return
            }

            self.showSnackbar(withMessage: R.string.localizable.gameStartedSnackMessage())
        }
    }

    @IBAction func onLastNightButtonPressed(_ btn: UIBarButtonItem) {
        let killedSeatIndices = game.value?.killedSeatIds.compactMap({ (seatID) -> String? in
            guard let i = seats.value?.index(where: { $0.id == seatID }) else {
                return nil
            }
            return String(i + 1)
        })
        guard let killedSeatString = killedSeatIndices?.joined(separator: ",") else {
            return
        }

        let msg = killedSeatString.isEmpty ? R.string.localizable.peacefulNightSnackMessage() : R.string.localizable.killedPlayersMessageTemplate(killedSeatString)
        showAlert(for: nil, orMessage: msg)
    }

    @IBAction func onUseSkillButtonPressed(_ btn: UIBarButtonItem) {
        guard let role = seatTaken?.role, let gameID = game.value?.id else {
            return
        }

        var req = Werewolf_TakeActionRequest()
        req.gameID = gameID
        switch role {
        case .seer,
             .guardian,
             .werewolf,
             .halfBlood:
            showSnackbar(withMessage: R.string.localizable.chooseTargetSnackMessage())
        case .hunter:
            req.hunter = Werewolf_TakeActionRequest.HunterAction()
            gameSrvClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (res) in
                    let msg = (res.seer.ruling == .positive) ? R.string.localizable.hunterActionRulingPositive() : R.string.localizable.hunterActionRulingNegative()
                    self.showSnackbar(withMessage: "\(msg)")
                })
                .disposed(by: disposeBag)
        case .witch:
            let killedSeatID = game.value?.killedSeatIds.first
            let killedSeatNumber = seats.value?.index(where: { (seat) -> Bool in
                seat.id == killedSeatID
            }) ?? 0 + 1
            let witchActionMessage = killedSeatID != nil ? R.string.localizable.witchActionKilledTemplate(killedSeatNumber) : R.string.localizable.witchActionNoDeath()
            let alert = UIAlertController(title: R.string.localizable.witchActionTitle(), message: witchActionMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.wtichActionSave(), style: .default, handler: { (_) in
                guard let cureSeatID = self.seats.value?.first(where: { (seat) -> Bool in
                    seat.id == killedSeatID
                })?.id else {
                    return
                }
                var req = Werewolf_TakeActionRequest()
                req.witch.cureSeatID = cureSeatID
                req.gameID = self.game.value?.id ?? ""
                self.gameSrvClient
                    .takeActionRx(req)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { (res) in
                        self.showSnackbar(withMessage: R.string.localizable.witchActionSaveSuccess())
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .disposed(by: self.disposeBag)
            }))
            alert.addTextField{ $0.placeholder = R.string.localizable.witchActionPoisonTextfieldPlaceholder() }
            alert.addAction(UIAlertAction(title: R.string.localizable.witchActionPoison(), style: .destructive, handler: { (_) in
                guard let text = alert.textFields?.first?.text,
                    let poisonSeatNumber = Int(text),
                    let poisonedSeatID = self.seats.value?[safe: poisonSeatNumber - 1]?.id,
                    let gameID = self.game.value?.id else {
                    return
                }

                var req = Werewolf_TakeActionRequest()
                req.witch.poisonSeatID = poisonedSeatID
                req.gameID = gameID
                self.gameSrvClient
                    .takeActionRx(req)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { (res) in
                        self.showSnackbar(withMessage: R.string.localizable.witchActionPoisonSuccess())
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .disposed(by: self.disposeBag)
            }))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }

    @IBAction func onReassignButtonPressed(_ btn: UIBarButtonItem) {
        var req = Werewolf_ReassignRolesRequest()
        req.roomID = roomID
        _ = try? gameSrvClient.reassignRoles(req) { (res, callResult) in
            guard res != nil else {
                self.showAlert(for: callResult)
                return
            }

            self.showAlert(for: nil, orMessage: R.string.localizable.reassignRoleSuccess())
        }
    }

    func tryHandleRoleSkill(_ seatButton: MDCButton) {
        guard let gameState = game.value?.state, let role = seatTaken?.role, let seatID = seats.value?[seatButton.number - 1].id, let gameID = game.value?.id else {
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
            gameSrvClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (res) in
                    let msg = (res.seer.ruling == .positive) ? R.string.localizable.seerActionRulingPositive() : R.string.localizable.seerActionRulingNegative()
                    self.showSnackbar(withMessage: "\(msg)")
                })
                .disposed(by: disposeBag)
        case .halfBloodAwake:
            if role != .halfBlood {
                return
            }
            req.halfBlood.seatID = seatID
            gameSrvClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (_) in
                    self.showSnackbar(withMessage: "榜样设立成功")
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        case .guardianAwake:
            if role != .guardian {
                return
            }
            req.guard.seatID = seatID
            gameSrvClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (_) in
                    self.showSnackbar(withMessage: "守卫成功")
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        case .werewolfAwake:
            if role != .werewolf && role != .whiteWerewolf {
                return
            }
            req.werewolf.seatID = seatID
            gameSrvClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (_) in
                    self.showSnackbar(withMessage: R.string.localizable.wolfKillSuccess())
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        default:
            break
        }
    }

    func tryHandleSeatTaking(_ seatButton: MDCButton) {
        guard let seatID = seats.value?[seatButton.number - 1].id,
            let hasUser = seats.value?[seatButton.number - 1].hasUser,
            !hasUser else {
            return
        }

        var req = Werewolf_TakeSeatRequest()
        req.seatID = seatID
        req.userID = userID

        gameSrvClient
            .takeSeatRx(req)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (_) in
                self.showSnackbar(withMessage: R.string.localizable.takeSeatSuccessTemplate(seatButton.number))
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

private extension RoomViewController {
     func initGetRoomStream() {
        var req = Werewolf_GetRoomRequest()
        req.roomID = self.roomID
        Observable<Int>
            .timer(RxTimeInterval(0), period: RxTimeInterval(0.5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { _ -> Observable<Werewolf_Room> in
                return Observable<Werewolf_Room>.create { observer -> Disposable in
                    let getRoomCall = try? self.gameSrvClient.getRoom(req) { (res, callResult) in
                        guard let room = res?.room else {
                            observer.onError(callResult)
                            return
                        }
                        observer.onNext(room)
                    }
                    return Disposables.create {
                        getRoomCall?.cancel()
                    }
                }
            }
            .distinctUntilChanged()
            .subscribe(onNext: { (room) in
                self.seats.accept(room.seats)
                self.game.accept(room.game)
            }, onError: { (error) in
                self.showAlert(for: nil, orMessage: (error as? CallResult)?.statusMessage)
            })
            .disposed(by: disposeBag)
    }

     func configureSeatsSubscription() {

        Observable
            .merge(seatButtons
                .compactMap { (button) -> Observable<MDCButton> in
                    return button.rx.tap.flatMapLatest({ (_) -> Observable<MDCButton> in
                        return Observable.just(button)
                    })
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (button) in
                self.tryHandleRoleSkill(button)
                self.tryHandleSeatTaking(button)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        let distinctSeats = seats
            .asObservable()
            .distinctUntilChanged()

        distinctSeats
            .subscribe(onNext: { (seats) in
                self.seatTaken = seats?.first(where: { (seat) -> Bool in
                    seat.user.id == self.userID
                })
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        distinctSeats
            .flatMapLatest{ (seats) -> Observable<Bool> in
                return Observable.create({ (observer) -> Disposable in
                    observer.onNext(seats?.first(where: { (seat) -> Bool in
                        seat.user.id == self.userID
                    }) == nil)
                    return Disposables.create()
                })
            }
            .bind(to: roleImageView.rx.isHidden)
            .disposed(by: disposeBag)

        distinctSeats
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (seatsOption) in
                guard let seats = seatsOption else {
                    return
                }

                for i in 0..<seats.count {
                    self.seatButtons[i].alpha = 1.0
                    self.seatButtons[i].backgroundColor = seats[i].hasUser ? .seatTaken : .seatVacant;
                }

                for i in seats.count..<self.seatButtons.count {
                    self.seatButtons[i].alpha = 0.0
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        let roleImage = distinctSeats
            .flatMapLatest{ (seats) -> Observable<UIImage?> in
                return Observable.create({ (observer) -> Disposable in
                    if let role = seats?.first(where: { (seat) -> Bool in
                        seat.user.id == self.userID
                    })?.role {
                        observer.onNext(UIImage.image(forRole: role))
                    }

                    return Disposables.create()
                })
            }

        Observable
            .combineLatest(roleImage, showingRole.asObservable()) { (role, showing) -> UIImage? in
                if !showing {
                    return #imageLiteral(resourceName: "卡背")
                }
                return role
            }
            .bind(to: roleImageView.rx.image)
            .disposed(by: disposeBag)
    }

    func configureGameSubscription() {
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
}
