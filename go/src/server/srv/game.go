package srv

import (
	"math/rand"
	proto "server/generated"
	"server/util"

	"time"

	"google.golang.org/grpc/codes"

	"fmt"
	"sync"

	"golang.org/x/net/context"
	"google.golang.org/grpc/status"
)

const (
	roomIdUpperLimit = int32(1000000)
	defaultRoomLimit = 2
	defaultUserLimit = 30
)

type GameService struct {
	rooms map[int32]*proto.Room
	users map[string]*proto.User
	mux   *sync.Mutex
	rnd   *rand.Rand
}

func NewGameService() *GameService {
	return &GameService{
		rooms: make(map[int32]*proto.Room),
		users: make(map[string]*proto.User),
		mux:   &sync.Mutex{},
		rnd:   rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

func (s *GameService) CreateAndJoinRoom(ctx context.Context, req *proto.CreateAndJoinRoomRequest) (*proto.CreateAndJoinRoomResponse, error) {
	if len(s.rooms) >= defaultRoomLimit {
		return nil, status.Error(codes.ResourceExhausted, "room limit reached")
	}

	roomId := s.generateRoomId()
	s.rooms[roomId] = &proto.Room{
		Id: roomId,
	}
	userId := s.generateUserId(roomId)
	user := &proto.User{
		Id: userId,
	}
	s.addUserToRoom(roomId, user)

	return &proto.CreateAndJoinRoomResponse{
		RoomId: roomId,
		UserId: userId,
	}, nil
}

func (s *GameService) generateRoomId() int32 {
	return s.rnd.Int31n(roomIdUpperLimit)
}

func (s *GameService) JoinRoom(ctx context.Context, req *proto.JoinRoomRequest) (*proto.JoinRoomResponse, error) {
	if err := s.validateJoinRoomRequest(req); err != nil {
		return nil, err
	}

	userId := req.GetUserId()
	if _, exist := s.users[userId]; !exist || util.IsEmptyOrWhiteSpace(userId) {
		userId = s.generateUserId(req.GetRoomId())
		s.users[userId] = &proto.User{
			Id: userId,
		}
	}
	s.addUserToRoom(req.RoomId, s.users[userId])

	return &proto.JoinRoomResponse{
		UserId: userId,
	}, nil
}

func (s *GameService) addUserToRoom(roomId int32, user *proto.User) {
	room := s.rooms[roomId]
	for _, u := range room.GetUsers() {
		if u.Id == user.Id {
			return
		}
	}
	room.Users = append(room.Users, user)
	return
}

func (s *GameService) generateUserId(roomId int32) string {
	return fmt.Sprintf("%d/%d", roomId, s.rnd.Int63())
}

func (s *GameService) validateJoinRoomRequest(req *proto.JoinRoomRequest) error {
	roomId := req.GetRoomId()
	if _, ok := s.rooms[roomId]; !ok {
		return status.Error(codes.NotFound, "room not found")
	}

	if len(s.users) >= defaultUserLimit {
		return status.Error(codes.ResourceExhausted, "user limit reached")
	}

	return nil
}

func (s *GameService) UpdateGameConfig(ctx context.Context, req *proto.UpdateGameConfigRequest) (*proto.UpdateGameConfigResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "UpdateGameConfig not implemented yet!")
}

func (s *GameService) ReassignRoles(ctx context.Context, req *proto.ReassignRolesRequest) (*proto.ReassignRolesResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "ReassignRoles not implemented yet!")
}

func (s *GameService) StartGame(ctx context.Context, req *proto.StartGameRequest) (*proto.StartGameResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "StartGame not implemented yet!")
}

func (s *GameService) GetFirstDayResult(ctx context.Context, req *proto.GetFirstDayResultRequest) (*proto.GetFirstDayResultResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetFirstDayResult not implemented yet!")
}

func (s *GameService) GetRole(ctx context.Context, req *proto.GetRoleRequest) (*proto.GetRoleResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetRole not implemented yet!")
}

func (s *GameService) GetGameState(ctx context.Context, req *proto.GetGameStateRequest) (*proto.GetGameStateResponse, error) {
	// TODO: implement this.
	return nil, status.Error(codes.Unimplemented, "GetGameState not implemented yet!")
}