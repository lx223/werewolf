package entity

import "server/util"

type User struct {
	Id     string
	ImgUrl string
}

func NewUser(roomId string) *User {
	return &User{
		Id: util.RandomUserId(roomId),
	}
}
