package entity

import "server/generated"

type Game struct {
	Id      string
	Roles   []werewolf.Role
	Seats   []Seat
	State   werewolf.Game_State
	Actions []*werewolf.TakeActionRequest
}
