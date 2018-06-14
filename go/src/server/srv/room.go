package srv

import (
	"math/rand"
	pb_room "server/generated"
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

type RoomService struct {
	rooms map[int32]*pb_room.Room
	users map[string]*pb_room.User
	mux   *sync.Mutex
	rnd   *rand.Rand
}

func NewRoomService() *RoomService {
	return &RoomService{
		rooms: make(map[int32]*pb_room.Room),
		users: make(map[string]*pb_room.User),
		mux:   &sync.Mutex{},
		rnd:   rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

func (s *RoomService) CreateRoom(ctx context.Context, req *pb_room.CreateRoomRequest) (*pb_room.CreateRoomResponse, error) {
	if len(s.rooms) >= defaultRoomLimit {
		return nil, status.Error(codes.ResourceExhausted, "room limit reached")
	}

	roomId := s.generateRoomId()
	s.rooms[roomId] = &pb_room.Room{
		Id: roomId,
	}

	return &pb_room.CreateRoomResponse{
		RoomId: roomId,
	}, nil
}

func (s *RoomService) generateRoomId() int32 {
	return s.rnd.Int31n(roomIdUpperLimit)
}

func (s *RoomService) JoinRoom(ctx context.Context, req *pb_room.JoinRoomRequest) (*pb_room.JoinRoomResponse, error) {
	if err := s.validateJoinRoomRequest(req); err != nil {
		return nil, err
	}

	user := &pb_room.User{
		Id: req.GetUserId(),
	}
	userId := req.GetUserId()
	if _, exist := s.users[userId]; !exist || util.IsEmptyOrWhileSpace(userId) {
		user.Id = s.generateUserId(req.GetRoomId())
	}

	s.addUserToRoom(req.RoomId, user)
	s.users[user.Id] = user

	return &pb_room.JoinRoomResponse{
		UserId: user.Id,
	}, nil
}

func (s *RoomService) addUserToRoom(roomId int32, user *pb_room.User) {
	room := s.rooms[roomId]
	for _, u := range room.GetUsers() {
		if u.Id == user.Id {
			return
		}
	}
	room.Users = append(room.Users, user)
	return
}

func (s *RoomService) generateUserId(roomId int32) string {
	return fmt.Sprintf("%d/%d", roomId, s.rnd.Int63())
}

func (s *RoomService) validateJoinRoomRequest(req *pb_room.JoinRoomRequest) error {
	roomId := req.GetRoomId()
	if _, ok := s.rooms[roomId]; !ok {
		return status.Error(codes.NotFound, "room not found")
	}

	if len(s.users) >= defaultUserLimit {
		return status.Error(codes.ResourceExhausted, "user limit reached")
	}

	return nil
}
