package entity

import (
	werewolf "github.com/lx223/werewolf-assistant/generated"
	"github.com/lx223/werewolf-assistant/util"
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
