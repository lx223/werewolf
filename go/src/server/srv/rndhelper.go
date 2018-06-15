package srv

import (
	"fmt"
	"server/generated"
	"strconv"
)

func (s *GameService) generateRoomId() int32 {
	return s.rnd.Int31n(roomIdUpperLimit)
}

func (s *GameService) generateUserId(roomId int32) string {
	return fmt.Sprintf("%d/%d", roomId, s.rnd.Int63())
}

func (s *GameService) shuffleRolesIntoSeats(roles []werewolf.Role, counts []int32) []*werewolf.Seat {
	var flattenedRoles []werewolf.Role
	for i, r := range roles {
		for c := int32(0); c < counts[i]; c++ {
			flattenedRoles = append(flattenedRoles, r)
		}
	}

	seats := make([]*werewolf.Seat, len(flattenedRoles))
	perm := s.rnd.Perm(len(flattenedRoles))
	for i, v := range perm {
		seats[v] = &werewolf.Seat{
			Id:   s.generateSeatId(),
			Role: flattenedRoles[i],
		}
	}
	return seats
}

func (s *GameService) generateSeatId() string {
	return strconv.FormatInt(s.rnd.Int63(), 16)
}
