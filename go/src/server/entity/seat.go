package entity

import (
	"server/generated"
	"server/util"
)

type Seat struct {
	Id   string
	Role werewolf.Role
	User *User
}

func NewSeat(roomId string) *Seat {
	return &Seat{
		Id: util.RandomSeatId(roomId),
	}
}
