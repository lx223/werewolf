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

class RoomViewController: UIViewController {

    @IBOutlet var seats: [SeatView]!
    @IBOutlet weak var roleImageView: UIImageView!

    private var seatTaken: Int?

    private var roomTitle: String {
        return "房间: \(self.roomID)"
    }

    private var showingRole = false

    private let gameSrvClient: Werewolf_GameServiceService
    private let userID: String
    private let roomID: String
    private let isHost: Bool
    private let disposeBag = DisposeBag()
    private let room = BehaviorRelay<Werewolf_Room?>(value: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        let roomLabel = UILabel()
        roomLabel.text = roomTitle
        let rightBarButtonItem = UIBarButtonItem(customView: roomLabel)
        navigationItem.setRightBarButton(rightBarButtonItem, animated: false)

        seats.sort { $0.number < $1.number }
        seats.forEach{ $0.attachRecogniser(numOfTap: 1, forTarget: self, withAction: #selector(onSeatPressed)) }

        roleImageView.attachRecogniser(numOfTap: 1, forTarget: self, withAction: #selector(onRoleImageViewPressed))
        roleImageView.isUserInteractionEnabled = true

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
            .observeOn(MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .subscribe(onNext: { (room) in
                self.room.accept(room)
            }, onError: { (error) in
                self.showAlert(for: nil, orMessage: (error as? CallResult)?.statusMessage)
            })
            .disposed(by: disposeBag)

        room
            .asObservable()
            .flatMapLatest({ room -> Observable<Werewolf_Seat?> in
                return Observable.create({ (observer) -> Disposable in
                    observer.onNext(room?.seats.filter{ $0.user.id == self.userID }.first)
                    return Disposables.create()
                })
            })
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (seat) in
                self.roleImageView.isHidden = seat == nil
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        room
            .asObservable()
            .flatMapLatest {
                Observable.of($0?.seats)
            }
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { (seatsOption) in
                guard let seats = seatsOption else {
                    return
                }

                for i in 0..<seats.count {
                    self.seats[i].alpha = 1.0
                    self.seats[i].taken = seats[i].hasUser
                }

                for i in seats.count..<self.seats.count {
                    self.seats[i].alpha = 0.0
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

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
        guard let view = sender.view as? UIImageView, let seat = seatTaken, let role = room.value?.seats[seat - 1].role else {
            return
        }
        
        if showingRole {
            view.image = #imageLiteral(resourceName: "卡背")
        } else {
            view.image = UIImage.image(forRole: role)
        }
        showingRole = !showingRole
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
        print("last night result")
    }

    @IBAction func onUseSkillButtonPressed(_ btn: UIBarButtonItem) {
        print("use skill")
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
        guard let seatView = sender.view as? SeatView, let seatID = room.value?.seats[seatView.number - 1].id else {
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
            self.seatTaken = seatView.number
        }
    }
}


