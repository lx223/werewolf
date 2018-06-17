package entity

import (
	"server/generated"
	"server/util"
	"sort"
	"sync"
)

type Room struct {
	Id    string
	Roles []werewolf.Role
	Seats map[string]*Seat
	Users map[string]*User
	Game  *Game

	mux *sync.Mutex
}

func NewRoom() *Room {
	return &Room{
		Id:    util.NewRoomId(),
		Roles: []werewolf.Role{},
		Seats: make(map[string]*Seat),
		Users: make(map[string]*User),

		mux: &sync.Mutex{},
	}
}

func (r *Room) StoreUser(user *User) {
	if user == nil {
		return
	}

	r.concurrentDo(func() {
		r.Users[user.Id] = user
	})
}

func (r *Room) StoreRoles(roles []werewolf.Role) {
	if len(roles) == 0 {
		return
	}

	r.concurrentDo(func() {
		r.Roles = roles
	})
}

func (r *Room) StoreSeats(seats []*Seat) {
	if seats == nil {
		return
	}

	r.concurrentDo(func() {
		for k := range r.Seats {
			delete(r.Seats, k)
		}
		for _, seat := range seats {
			r.Seats[seat.Id] = seat
		}
	})
}

func (r *Room) GetSortedSeats() []*Seat {
	var seats []*Seat
	for _, v := range r.Seats {
		seats = append(seats, v)
	}
	sort.Sort(BySeatIndex(seats))
	return seats
}

func (r *Room) ToProto() *werewolf.Room {
	if r == nil {
		return nil
	}

	var gameId string
	if r.Game != nil {
		gameId = r.Game.Id
	}

	var seatsProto []*werewolf.Seat
	for _, s := range r.GetSortedSeats() {
		seatsProto = append(seatsProto, s.ToProto())
	}

	return &werewolf.Room{
		Seats:  seatsProto,
		GameId: gameId,
	}
}

func (r *Room) concurrentDo(f func()) {
	r.mux.Lock()
	defer r.mux.Unlock()

	f()
}
