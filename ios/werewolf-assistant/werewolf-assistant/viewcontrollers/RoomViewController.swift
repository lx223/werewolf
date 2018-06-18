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

class RoomViewController: UIViewController {

    @IBOutlet var seatViews: [SeatView]!
    @IBOutlet weak var roleImageView: UIImageView!

    private var seatTaken: Werewolf_Seat?
    private var seerAction = false

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
        guard let role = seatTaken?.role else {
            return
        }

        switch role {
        case .seer:
            showAlert(for: nil, orMessage: "点击要验的💺")
            seerAction = true
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
        if seerAction {
            guard let seatView = sender.view as? SeatView, let role = seats.value?[seatView.number - 1].role else {
                return
            }

            showAlert(for: nil, orMessage: "\(role)")
            return
        }

        guard let seatView = sender.view as? SeatView, let seatID = seats.value?[seatView.number - 1].id else {
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

            self.showAlert(for: nil, orMessage: "Took seat \(seatView.number)")
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
            .distinctUntilChanged()
            .subscribe(onNext: { (gameOptional) in
                guard let game = gameOptional else {
                    return
                }

                switch game.state {
                case .darknessFalls:
                    Sound.play(file: "darkness_falls.mp3")
                case .orphanAwake: break
                case .halfBloodAwake: break
                case .guardianAwake: break
                case .werewolfAwake: break
                case .witchAwake: break
                case .seerAwake: break
                case .hunterAwake: break
                case .whiteWerewolfAwake: break
                case .sheriffElection: break
                default:
                    break
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
