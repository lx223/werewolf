package util

import (
	"math/rand"
	"time"

	werewolf "github.com/lx223/werewolf-assistant/generated"
)

var rnd *rand.Rand

func init() {
	rnd = rand.New(rand.NewSource(time.Now().UnixNano()))
}

func RandomInt32WithLimit(limit int32) int32 {
	return rand.Int31n(limit)
}

func RandomInt64() int64 {
	return rnd.Int63()
}

func Shuffle(roles []werewolf.Role) []werewolf.Role {
	var dst = make([]werewolf.Role, len(roles))
	perm := rnd.Perm(len(roles))
	for i, v := range perm {
		dst[i] = roles[v]
	}
	return dst
}
