package util

import (
	"fmt"
	"math/rand"
	"server/generated"
	"strconv"
	"time"
)

var rnd *rand.Rand

const roomIdUpperLimit = int32(1000000)

func init() {
	rnd = rand.New(rand.NewSource(time.Now().UnixNano()))
}

func RandomRoomId() string {
	return fmt.Sprintf("%d", rnd.Int31n(roomIdUpperLimit))
}

func RandomSeatId(roomId string) string {
	return fmt.Sprintf("%s/%s", roomId, randomInt64())
}

func RandomUserId(roomId string) string {
	return fmt.Sprintf("%s/%s", roomId, randomInt64())
}

func randomInt64() string {
	return strconv.FormatInt(rnd.Int63(), 16)
}

func Shuffle(roles []werewolf.Role) []werewolf.Role {
	var dst = make([]werewolf.Role, len(roles))
	perm := rnd.Perm(len(roles))
	for i, v := range perm {
		dst[i] = roles[v]
	}
	return dst
}
