package util

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
)

const (
	separator        = "/"
	roomIdUpperLimit = int32(1000000)
)

func NewRoomId() string {
	return fmt.Sprintf("%d", rnd.Int31n(roomIdUpperLimit))
}

func NewSeatId(roomId string) string {
	return fmt.Sprintf("%s%s%d", roomId, separator, RandomInt64())
}

func NewUserId(roomId string) string {
	return fmt.Sprintf("%s%s%d", roomId, separator, RandomInt64())
}

func NewGameId(roomId string) string {
	return fmt.Sprintf("%s%s%d", roomId, separator, RandomInt64())
}

func GetRoomId(id string) (string, error) {
	parts := strings.Split(id, "/")
	if len(parts) != 2 {
		return "", errors.New("wrong id format")
	}

	i, err := strconv.ParseInt(parts[0], 10, 32)
	if err != nil {
		return "", errors.New("room id part not int32")
	}

	if i < 0 || i >= int64(roomIdUpperLimit) {
		return "", errors.New("room id not within valid range")
	}

	return parts[0], nil
}
