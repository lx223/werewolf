package srv

import (
	werewolf "github.com/lx223/werewolf-assistant/generated"

	"github.com/lx223/werewolf-assistant/util"

	"github.com/lx223/werewolf-assistant/entity"

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

	if len(req.GetRoleCounts()) == 0 {
		return status.Error(codes.InvalidArgument, "empty config")
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
	case werewolf.Role_VILLAGER,
		werewolf.Role_WEREWOLF:
		if count <= 0 {
			return newRoleCountErr(role)
		}
	case werewolf.Role_SEER,
		werewolf.Role_WITCH,
		werewolf.Role_HUNTER,
		werewolf.Role_IDIOT,
		werewolf.Role_GUARDIAN,
		werewolf.Role_WHITE_WEREWOLF,
		werewolf.Role_HALF_BLOOD:
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
	roomId, err := util.GetRoomId(userId)
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

func (s *GameService) validateVacateSeatRequest(req *werewolf.VacateSeatRequest) error {
	roomId, err := util.GetRoomId(req.GetSeatId())
	if err != nil {
		return status.Errorf(codes.InvalidArgument, "invalid seat id %s", req.GetSeatId())
	}
	if _, ok := s.rooms[roomId]; !ok {
		return status.Errorf(codes.InvalidArgument, "room cannot be found for seat id %s", req.GetSeatId())
	}

	return nil
}

func (s *GameService) validateStartGameRequest(req *werewolf.StartGameRequest) error {
	roomId := req.GetRoomId()
	room, ok := s.rooms[roomId]
	if !ok {
		return status.Error(codes.InvalidArgument, "room not found")
	}

	for _, seat := range room.GetSortedSeats() {
		if seat.User == nil {
			return status.Error(codes.FailedPrecondition, "not all seats taken")
		}
	}

	return nil
}

func (s *GameService) validateTakeActionRequest(req *werewolf.TakeActionRequest) error {
	gameId := req.GetGameId()
	roomId, err := util.GetRoomId(gameId)
	if err != nil {
		return status.Error(codes.InvalidArgument, err.Error())
	}

	room, ok := s.rooms[roomId]
	if !ok {
		return status.Error(codes.InvalidArgument, "room not found")
	}

	game := room.Game
	if game == nil || game.Id != gameId {
		return status.Error(codes.InvalidArgument, "game not found")
	}

	switch req.GetAction().(type) {
	case *werewolf.TakeActionRequest_Guard:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_GUARDIAN_AWAKE)
	case *werewolf.TakeActionRequest_HalfBlood:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_HALF_BLOOD_AWAKE)
	case *werewolf.TakeActionRequest_Orphan:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_ORPHAN_AWAKE)
	case *werewolf.TakeActionRequest_Hunter:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_HUNTER_AWAKE)
	case *werewolf.TakeActionRequest_Seer:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_SEER_AWAKE)
	case *werewolf.TakeActionRequest_Werewolf:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_WEREWOLF_AWAKE)
	case *werewolf.TakeActionRequest_Witch:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_WITCH_AWAKE)
	case *werewolf.TakeActionRequest_Sheriff:
		return validateRequiredActionStateAgainstGameState(game, werewolf.Game_SHERIFF_ELECTION)
	default:
		return status.Error(codes.InvalidArgument, "unsupported action")
	}

	return nil
}

func validateRequiredActionStateAgainstGameState(game *entity.Game, requiredState werewolf.Game_State) error {
	if game.State != requiredState {
		return status.Errorf(codes.FailedPrecondition, "game state: %s, required state: %s", game.State.String(), requiredState.String())
	}
	return nil
}
