package srv

import (
	"server/generated"

	"server/util"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *GameService) validateJoinRoomRequest(req *werewolf.JoinRoomRequest) error {
	room, ok := s.rooms[req.GetRoomId()]
	if !ok {
		return status.Error(codes.NotFound, "room not found")
	}

	if len(room.Users) >= defaultUserLimit {
		return status.Error(codes.ResourceExhausted, "user limit reached")
	}

	return nil
}

func (s *GameService) validateUpdateGameConfig(req *werewolf.UpdateGameConfigRequest) error {
	roomId := req.GetRoomId()
	if _, ok := s.rooms[roomId]; !ok {
		return status.Error(codes.NotFound, "room not found")
	}

	for _, roleCount := range req.GetRoleCounts() {
		if err := validateRoleCount(roleCount.Role, roleCount.Count); err != nil {
			return err
		}
	}

	return nil
}

func validateRoleCount(role werewolf.Role, count int32) error {
	switch role {
	case werewolf.Role_VILLAGER:
	case werewolf.Role_WEREWOLF:
		if count <= 0 {
			return newRoleCountErr(role)
		}
	case werewolf.Role_SEER:
	case werewolf.Role_WITCH:
	case werewolf.Role_HUNTER:
	case werewolf.Role_IDIOT:
	case werewolf.Role_GUARDIAN:
	case werewolf.Role_WHITE_WEREWOLF:
	case werewolf.Role_HALF_BLOOD:
		if count > 1 || count < 0 {
			return newRoleCountErr(role)
		}
	default:
		return status.Errorf(codes.InvalidArgument, "%s not supported", role.String())
	}
	return nil
}

func newRoleCountErr(role werewolf.Role) error {
	return status.Errorf(codes.InvalidArgument, "wrong count for %s", role.String())
}

func (s *GameService) validateGetRoomReq(req *werewolf.GetRoomRequest) error {
	roomId := req.GetRoomId()
	if _, ok := s.rooms[roomId]; !ok {
		return status.Error(codes.NotFound, "room not found")
	}
	return nil
}

func (s *GameService) validateTakeSeatRequest(req *werewolf.TakeSeatRequest) error {
	userId := req.GetUserId()
	seatId := req.GetSeatId()
	roomId, err := util.GetRoomIdFromSeatIdOrUserId(userId)
	if err != nil {
		return status.Error(codes.InvalidArgument, err.Error())
	}

	room, ok := s.rooms[roomId]
	if !ok {
		return status.Error(codes.InvalidArgument, "invalid user id or seat id")
	}

	if _, ok := room.Users[userId]; !ok {
		return status.Error(codes.NotFound, "user not found")
	}

	if _, ok := room.Seats[seatId]; !ok {
		return status.Error(codes.NotFound, "seat not found")
	}

	return nil
}

func (s *GameService) validateReassignRolesRequest(req *werewolf.ReassignRolesRequest) error {
	roomId := req.GetRoomId()
	if _, ok := s.rooms[roomId]; !ok {
		return status.Error(codes.InvalidArgument, "invalid user id or seat id")
	}

	return nil
}
