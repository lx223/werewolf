package srv

import (
	"math/rand"
	"server/generated"
	"server/util"

	"time"

	"google.golang.org/grpc/codes"

	"sync"

	"golang.org/x/net/context"
	"google.golang.org/grpc/status"
)

const (
	roomIdUpperLimit = int32(1000000)
	defaultRoomLimit = 20000
	defaultUserLimit = 30
)

type GameService struct {
	rooms map[int32]*werewolf.Room
	users map[string]*werewolf.User
	mux   *sync.Mutex
	rnd   *rand.Rand
}

func NewGameService() *GameService {
	return &GameService{
		rooms: make(map[int32]*werewolf.Room),
		users: make(map[string]*werewolf.User),
		mux:   &sync.Mutex{},
		rnd:   rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

func (s *GameService) CreateAndJoinRoom(ctx context.Context, req *werewolf.CreateAndJoinRoomRequest) (*werewolf.CreateAndJoinRoomResponse, error) {
	if len(s.rooms) >= defaultRoomLimit {
		return nil, status.Error(codes.ResourceExhausted, "room limit reached")
	}

	roomId := s.generateRoomId()
	s.rooms[roomId] = &werewolf.Room{
		Id: roomId,
	}
	userId := s.generateUserId(roomId)
	user := &werewolf.User{
		Id: userId,
	}
	s.addUserToRoom(roomId, user)

	return &werewolf.CreateAndJoinRoomResponse{
		RoomId: roomId,
		UserId: userId,
	}, nil
}

func (s *GameService) JoinRoom(ctx context.Context, req *werewolf.JoinRoomRequest) (*werewolf.JoinRoomResponse, error) {
	if err := s.validateJoinRoomRequest(req); err != nil {
		return nil, err
	}

	userId := req.GetUserId()
	if _, exist := s.users[userId]; !exist || util.IsEmptyOrWhiteSpace(userId) {
		userId = s.generateUserId(req.GetRoomId())
		s.users[userId] = &werewolf.User{
			Id: userId,
		}
	}
	s.addUserToRoom(req.RoomId, s.users[userId])

	return &werewolf.JoinRoomResponse{
		UserId: userId,
	}, nil
}

func (s *GameService) addUserToRoom(roomId int32, user *werewolf.User) {
	room := s.rooms[roomId]
	for _, u := range room.GetUsers() {
		if u.Id == user.Id {
			return
		}
	}
	room.Users = append(room.Users, user)
	return
}

func (s *GameService) UpdateGameConfig(ctx context.Context, req *werewolf.UpdateGameConfigRequest) (*werewolf.UpdateGameConfigResponse, error) {
	if err := s.validateUpdateGameConfig(req); err != nil {
		return nil, err
	}

	room := s.rooms[req.GetRoomId()]
	room.Seats = s.shuffleRolesIntoSeats(req.GetRoles(), req.GetCounts())

	return &werewolf.UpdateGameConfigResponse{
		Room: room,
	}, nil
}

func (s *GameService) ReassignRoles(ctx context.Context, req *werewolf.ReassignRolesRequest) (*werewolf.ReassignRolesResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "ReassignRoles not implemented yet!")
}

func (s *GameService) StartGame(ctx context.Context, req *werewolf.StartGameRequest) (*werewolf.StartGameResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "StartGame not implemented yet!")
}

func (s *GameService) GetFirstDayResult(ctx context.Context, req *werewolf.GetFirstDayResultRequest) (*werewolf.GetFirstDayResultResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetFirstDayResult not implemented yet!")
}

func (s *GameService) GetRole(ctx context.Context, req *werewolf.GetRoleRequest) (*werewolf.GetRoleResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetRole not implemented yet!")
}

func (s *GameService) GetGameState(ctx context.Context, req *werewolf.GetGameStateRequest) (*werewolf.GetGameStateResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetGameState not implemented yet!")
}

func (s *GameService) TakeSeat(ctx context.Context, req *werewolf.TakeSeatRequest) (*werewolf.TakeSeatResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "TakeSeat not implemented yet!")
}
