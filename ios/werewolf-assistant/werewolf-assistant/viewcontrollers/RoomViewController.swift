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

    @IBOutlet var seatViews: [SeatView]!
    @IBOutlet weak var roleImageView: UIImageView!

    private var seatTaken: Werewolf_Seat?

    private var disposeBag = DisposeBag()

    private let gameSrvClient: Werewolf_GameServiceService
    private let userID: String
    private let roomID: String
    private let isHost: Bool

    private let game = BehaviorRelay<Werewolf_Game?>(value: nil)
    private let seats = BehaviorRelay<[Werewolf_Seat]?>(value: nil)
    private let showingRole = BehaviorRelay<Bool>(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        let roomLabel = UILabel()
        roomLabel.text = "房间: \(roomID)"
        let rightBarButtonItem = UIBarButtonItem(customView: roomLabel)
        navigationItem.setRightBarButton(rightBarButtonItem, animated: false)

        seatViews.sort { $0.number < $1.number }
        seatViews.forEach{ $0.attachRecogniser(numOfTap: 1, forTarget: self, withAction: #selector(onSeatPressed)) }

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

            self.showAlert(for: nil, orMessage: "game started")
        }
    }

    @IBAction func onLastNightButtonPressed(_ btn: UIBarButtonItem) {
        guard let deadPlayerString = game.value?.deadPlayerNumbers.joined(separator: ",") else {
            return
        }

        var msg = "昨夜是平安夜"
        if !deadPlayerString.isEmpty {
            msg = "昨夜死亡的玩家: \(deadPlayerString)"
        }
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
            showSnackbar(withMessage: "请选择目标💺")
        case .hunter:
            req.hunter = Werewolf_TakeActionRequest.HunterAction()
            gameSrvClient
                .takeActionRx(req)
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { (res) in
                    self.showSnackbar(withMessage: "\(res.hunter.ruling)")
                })
                .disposed(by: disposeBag)
        case .witch:
            let alert = UIAlertController(title: "女巫", message: "今晚死的是：", preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "救谁" }
            alert.addTextField{ $0.placeholder = "毒谁" }
            alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (_) in
                let curedSeatNumber = Int(alert.textFields?.first?.text ?? "")
                let poisonedSeatNumber = Int(alert.textFields?.last?.text ?? "")

                var curedSeatID = ""
                var poisonedSeatID = ""
                if let num = curedSeatNumber {
                    curedSeatID = self.seats.value?[num - 1].id ?? ""
                }
                if let num = poisonedSeatNumber {
                    poisonedSeatID = self.seats.value?[num - 1].id ?? ""
                }

                var req = Werewolf_TakeActionRequest()
                req.witch.cureSeatID = curedSeatID
                req.witch.poisonSeatID = poisonedSeatID
                req.gameID = self.game.value?.id ?? ""
                self.gameSrvClient
                    .takeActionRx(req)
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { (res) in
                        self.showSnackbar(withMessage: "操作成功")
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .disposed(by: self.disposeBag)
            }))
            alert.addAction(UIAlertAction(title: "不使用", style: .cancel, handler: nil))
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

            self.showAlert(for: nil, orMessage: "Reassigned roles")
        }
    }

    @objc func onSeatPressed(_ sender: UITapGestureRecognizer) {
        guard let seatViewPressed = sender.view as? SeatView else {
            return
        }

        tryHandleRoleSkill(seatViewPressed)
        tryHandleSeatTaking(seatViewPressed)
    }

    func tryHandleRoleSkill(_ seatView: SeatView) {
        guard let gameState = game.value?.state, let role = seatTaken?.role, let seatID = seats.value?[seatView.number - 1].id, let gameID = game.value?.id else {
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
                    self.showSnackbar(withMessage: "\(res.seer.ruling)")
                })
                .disposed(by: disposeBag)
        case .halfBloodAwake:
            if role != .halfBlood {
                return
            }
            req.halfBlood.seatID = seatID
            gameSrvClient
                .takeActionRx(req)
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
                .subscribe(onNext: { (_) in
                    self.showSnackbar(withMessage: "🔪人成功")
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        default:
            break
        }
    }

    func tryHandleSeatTaking(_ seatView: SeatView) {
        guard let seatID = seats.value?[seatView.number - 1].id,
            let hasUser = seats.value?[seatView.number - 1].hasUser,
            !hasUser else {
            return
        }

        var req = Werewolf_TakeSeatRequest()
        req.seatID = seatID
        req.userID = userID

        _ = try? gameSrvClient.takeSeat(req) { (res, callResult) in
            guard let _ = res else {
                self.showAlert(for: callResult)
                return
            }

            self.showSnackbar(withMessage: "Took seat \(seatView.number)")
        }
    }
}

private extension RoomViewController {
     func initGetRoomStream() {
        var req = Werewolf_GetRoomRequest()
        req.roomID = self.roomID
        Observable<Int>
            .timer(RxTimeInterval(0), period: RxTimeInterval(2), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
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
                    self.seatViews[i].alpha = 1.0
                    self.seatViews[i].taken = seats[i].hasUser
                }

                for i in seats.count..<self.seatViews.count {
                    self.seatViews[i].alpha = 0.0
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
            .scan(nil, accumulator: { (previous, current) -> Werewolf_Game.State? in
                if let state = previous {
                    self.playClosingSound(forState: state)
                }

                return current
            })
            .subscribe(onNext: { (stateOptional) in
                guard let state = stateOptional else {
                    return
                }

                self.playOpeningSound(forState: state)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

    func playClosingSound(forState state: Werewolf_Game.State) {
        switch state {
        case .unknown:
            Sound.darkness.play()
        case .orphanAwake:
            Sound.orphanClosing.play()
        case .halfBloodAwake:
            Sound.halfBloodClosing.play()
        case .guardianAwake:
            Sound.guardClosing.play()
        case .werewolfAwake:
            Sound.werewolfClosing.play()
        case .witchAwake:
            Sound.witchClosing.play()
        case .seerAwake:
            Sound.seerClosing.play()
        case .hunterAwake:
            Sound.hunterClosing.play()
        default:
            break
        }
    }

    func playOpeningSound(forState state: Werewolf_Game.State) {
        switch state {
            case .orphanAwake:
                Sound.orphanOpening.play()
            case .halfBloodAwake:
                Sound.halfBloodOpening.play()
            case .guardianAwake:
                Sound.guardOpening.play()
            case .werewolfAwake:
                Sound.werewolfOpening.play()
            case .witchAwake:
                Sound.witchOpening.play()
            case .seerAwake:
                Sound.seerOpening.play()
            case .hunterAwake:
                Sound.hunterOpening.play()
            default:
                break
        }
    }
}
