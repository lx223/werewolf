package entity

import (
	"server/generated"
	"server/util"
)

type User struct {
	Id     string
	ImgUrl string
}

func NewUser(roomId string) *User {
	return &User{
		Id: util.NewUserId(roomId),
	}
}

func (u *User) ToProto() *werewolf.User {
	if u == nil {
		return nil
	}

	return &werewolf.User{
		Id:     u.Id,
		ImgUrl: u.ImgUrl,
	}
}
