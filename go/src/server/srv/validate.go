package srv

import (
	proto "server/generated"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *GameService) validateJoinRoomRequest(req *proto.JoinRoomRequest) error {
	if err := s.validateRoomId(req.GetRoomId()); err != nil {
		return err
	}

	if len(s.users) >= defaultUserLimit {
		return status.Error(codes.ResourceExhausted, "user limit reached")
	}

	return nil
}

func (s *GameService) validateRoomId(roomId int32) error {
	if _, ok := s.rooms[roomId]; !ok {
		return status.Error(codes.NotFound, "room not found")
	}
	return nil
}

func (s *GameService) validateUpdateGameConfig(req *proto.UpdateGameConfigRequest) error {
	if err := s.validateRoomId(req.GetRoomId()); err != nil {
		return err
	}

	if len(req.GetRoles()) != len(req.GetCounts()) || len(req.GetRoles()) == 0 {
		return status.Error(codes.InvalidArgument, "invalid role config")
	}

	for i, r := range req.GetRoles() {
		if err := validateRoleCount(r, req.GetCounts()[i]); err != nil {
			return err
		}
	}

	return nil
}

func validateRoleCount(role proto.Role, count int32) error {
	switch role {
	case proto.Role_VILLAGER:
	case proto.Role_WEREWOLF:
		if count <= 0 {
			return newRoleCountErr(role)
		}
	case proto.Role_SEER:
	case proto.Role_WITCH:
	case proto.Role_HUNTER:
	case proto.Role_IDIOT:
	case proto.Role_GUARDIAN:
	case proto.Role_WHITE_WEREWOLF:
	case proto.Role_HALF_BLOOD:
		if count > 1 || count < 0 {
			return newRoleCountErr(role)
		}
	}
	return nil
}

func newRoleCountErr(role proto.Role) error {
	return status.Errorf(codes.InvalidArgument, "wrong count for %s", role.String())
}
