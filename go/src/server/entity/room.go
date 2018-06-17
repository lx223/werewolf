package entity

import (
	"server/generated"
	"server/util"
	"sync"
)

type Room struct {
	Id    string
	Roles []werewolf.Role
	Seats map[string]*Seat
	Users map[string]*User
	Games map[string]*Game

	mux *sync.Mutex
}

func NewRoom() *Room {
	return &Room{
		Id: util.RandomRoomId(),

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

func (r *Room) StoreSeat(seat *Seat) {
	if seat == nil {
		return
	}

	r.concurrentDo(func() {
		r.Seats[seat.Id] = seat
	})
}

func (r *Room) concurrentDo(f func()) {
	r.mux.Lock()
	defer r.mux.Unlock()

	f()
}
