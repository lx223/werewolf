package srv

import (
	"server/generated"

	"google.golang.org/grpc/codes"

	"sync"

	"server/entity"

	"server/util"

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

	for _, role := range util.Shuffle(roles) {
		seat := entity.NewSeat(room.Id)
		seat.Role = role
		room.StoreSeat(seat)
	}

	return &werewolf.UpdateGameConfigResponse{}, nil
}

func (s *GameService) GetRoom(ctx context.Context, req *werewolf.GetRoomRequest) (*werewolf.GetRoomResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (s *GameService) TakeSeat(ctx context.Context, req *werewolf.TakeSeatRequest) (*werewolf.TakeSeatResponse, error) {
	return nil, status.Error(codes.Unimplemented, "not implemented")
}

func (s *GameService) ReassignRoles(ctx context.Context, req *werewolf.ReassignRolesRequest) (*werewolf.ReassignRolesResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "ReassignRoles not implemented yet!")
}

func (s *GameService) StartGame(ctx context.Context, req *werewolf.StartGameRequest) (*werewolf.StartGameResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "StartGame not implemented yet!")
}

func (s *GameService) GetGame(ctx context.Context, req *werewolf.GetGameRequest) (*werewolf.GetGameResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetGameState not implemented yet!")
}

func (s *GameService) TakeAction(ctx context.Context, req *werewolf.TakeActionRequest) (*werewolf.TakeActionResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "not implemented")
}
