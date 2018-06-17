package entity

import (
	"server/generated"
	"server/util"
)

type Seat struct {
	Id   string
	Role werewolf.Role
	User *User

	index int
}

func NewSeat(roomId string, index int) *Seat {
	return &Seat{
		Id:    util.NewSeatId(roomId),
		index: index,
	}
}
func (s *Seat) ToProto() *werewolf.Seat {
	if s == nil {
		return nil
	}

	return &werewolf.Seat{
		Id:   s.Id,
		Role: s.Role,
		User: s.User.ToProto(),
	}
}

type BySeatIndex []*Seat

func (s BySeatIndex) Len() int {
	return len(s)
}
func (s BySeatIndex) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}
func (s BySeatIndex) Less(i, j int) bool {
	return s[i].index < s[j].index
}
