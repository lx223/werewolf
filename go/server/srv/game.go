package srv

import (
	"github.com/lx223/werewolf-assistant/generated"

	"google.golang.org/grpc/codes"

	"sync"

	"github.com/lx223/werewolf-assistant/entity"

	"github.com/lx223/werewolf-assistant/util"

	"golang.org/x/net/context"
	"google.golang.org/grpc/status"
)

const (
	defaultRoomLimit = 20000
	defaultUserLimit = 30
)

type GameService struct {
	rooms map[string]*entity.Room
	mux   *sync.Mutex
}

func NewGameService() *GameService {
	return &GameService{
		rooms: make(map[string]*entity.Room),
		mux:   &sync.Mutex{},
	}
}

func (s *GameService) CreateAndJoinRoom(ctx context.Context, req *werewolf.CreateAndJoinRoomRequest) (*werewolf.CreateAndJoinRoomResponse, error) {
	if len(s.rooms) >= defaultRoomLimit {
		return nil, status.Error(codes.ResourceExhausted, "room limit reached")
	}

	room := entity.NewRoom()
	user := entity.NewUser(room.Id)
	room.Users[user.Id] = user
	room.HostId = user.Id

	s.mux.Lock()
	defer s.mux.Unlock()

	s.rooms[room.Id] = room

	return &werewolf.CreateAndJoinRoomResponse{
		RoomId: room.Id,
		UserId: user.Id,
	}, nil
}

func (s *GameService) JoinRoom(ctx context.Context, req *werewolf.JoinRoomRequest) (*werewolf.JoinRoomResponse, error) {
	if err := s.validateJoinRoomRequest(req); err != nil {
		return nil, err
	}

	roomId := req.GetRoomId()
	userId := req.GetUserId()

	room := s.rooms[roomId]
	if _, exist := room.Users[userId]; !exist {
		newUser := entity.NewUser(roomId)
		room.StoreUser(newUser)
		userId = newUser.Id
	}

	return &werewolf.JoinRoomResponse{
		UserId: userId,
	}, nil
}

func (s *GameService) UpdateGameConfig(ctx context.Context, req *werewolf.UpdateGameConfigRequest) (*werewolf.UpdateGameConfigResponse, error) {
	if err := s.validateUpdateGameConfig(req); err != nil {
		return nil, err
	}

	room := s.rooms[req.GetRoomId()]

	var roles []werewolf.Role
	for _, roleCount := range req.GetRoleCounts() {
		for i := 0; i < int(roleCount.Count); i++ {
			roles = append(roles, roleCount.Role)
		}
	}
	room.StoreRoles(roles)

	var seats []*entity.Seat
	for i, role := range util.Shuffle(roles) {
		seat := entity.NewSeat(room.Id, i)
		seat.Role = role
		seats = append(seats, seat)
	}
	room.StoreSeats(seats)

	room.Game = nil

	return &werewolf.UpdateGameConfigResponse{}, nil
}

func (s *GameService) GetRoom(ctx context.Context, req *werewolf.GetRoomRequest) (*werewolf.GetRoomResponse, error) {
	if err := s.validateGetRoomReq(req); err != nil {
		return nil, err
	}

	room := s.rooms[req.GetRoomId()]
	return &werewolf.GetRoomResponse{
		Room: room.ToProto(),
	}, nil
}

func (s *GameService) TakeSeat(ctx context.Context, req *werewolf.TakeSeatRequest) (*werewolf.TakeSeatResponse, error) {
	if err := s.validateTakeSeatRequest(req); err != nil {
		return nil, err
	}

	seatId := req.GetSeatId()
	userId := req.GetUserId()
	roomId, _ := util.GetRoomId(seatId)

	room := s.rooms[roomId]

	for _, seat := range room.GetSortedSeats() {
		if seat.User != nil && seat.User.Id == userId && seat.Id != seatId {
			seat.User = nil
		}
	}

	seat := room.Seats[seatId]
	user := room.Users[userId]
	seat.User = user
	return &werewolf.TakeSeatResponse{}, nil
}

func (s *GameService) ReassignRoles(ctx context.Context, req *werewolf.ReassignRolesRequest) (*werewolf.ReassignRolesResponse, error) {
	if err := s.validateReassignRolesRequest(req); err != nil {
		return nil, err
	}

	room := s.rooms[req.GetRoomId()]
	newRoles := util.Shuffle(room.Roles)

	for i, seat := range room.GetSortedSeats() {
		seat.Role = newRoles[i]
	}
	room.Game = nil

	return &werewolf.ReassignRolesResponse{}, nil
}

func (s *GameService) VacateSeat(ctx context.Context, req *werewolf.VacateSeatRequest) (*werewolf.VacateSeatResponse, error) {
	if err := s.validateVacateSeatRequest(req); err != nil {
		return nil, err
	}

	s.mux.Lock()
	defer s.mux.Unlock()

	roomId, _ := util.GetRoomId(req.GetSeatId())
	s.rooms[roomId].Seats[req.GetSeatId()].User = nil

	return &werewolf.VacateSeatResponse{}, nil
}

func (s *GameService) StartGame(ctx context.Context, req *werewolf.StartGameRequest) (*werewolf.StartGameResponse, error) {
	if err := s.validateStartGameRequest(req); err != nil {
		return nil, err
	}

	roomId := req.GetRoomId()
	room := s.rooms[roomId]

	seatsCopy := make(map[string]*entity.Seat)
	for k, seat := range room.Seats {
		var seatCopy = *seat
		seatsCopy[k] = &seatCopy
	}
	room.Game = entity.NewGame(roomId, room.Roles, seatsCopy)

	return &werewolf.StartGameResponse{}, nil
}

func (s *GameService) TakeAction(ctx context.Context, req *werewolf.TakeActionRequest) (*werewolf.TakeActionResponse, error) {
	if err := s.validateTakeActionRequest(req); err != nil {
		return nil, err
	}

	gameId := req.GetGameId()
	roomId, _ := util.GetRoomId(gameId)

	room := s.rooms[roomId]
	game := room.Game
	game.AdvanceToNextState()

	var res = &werewolf.TakeActionResponse{}
	switch action := req.GetAction().(type) {
	case *werewolf.TakeActionRequest_Witch:
		game.WitchCureSeatId = action.Witch.CureSeatId
		game.WitchPoisonSeatId = action.Witch.PoisonSeatId
	case *werewolf.TakeActionRequest_Werewolf:
		game.WerewolfKillSeatId = action.Werewolf.SeatId
	case *werewolf.TakeActionRequest_Guard:
		game.GuardSeatId = action.Guard.SeatId
	case *werewolf.TakeActionRequest_Hunter:
		res.Result = &werewolf.TakeActionResponse_Hunter{Hunter: &werewolf.TakeActionResponse_HunterResult{
			Ruling: game.HunterAction(),
		}}
	case *werewolf.TakeActionRequest_Seer:
		res.Result = &werewolf.TakeActionResponse_Seer{Seer: &werewolf.TakeActionResponse_SeerResult{
			Ruling: game.SeerAction(action.Seer.SeatId),
		}}
	}

	return res, nil
}
