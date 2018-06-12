package room

import (
	"math/rand"
	pb_room "server/generated/room"
	"sync"
	"time"

	"google.golang.org/grpc/codes"

	"golang.org/x/net/context"
	"google.golang.org/grpc/status"
)

const (
	roomUpperLimit    = int32(1000000)
	maxConcurrentRoom = 2
)

type RoomService struct {
	rooms *concurrentRoomMap
	rnd   *rand.Rand
}

func NewRoomService() *RoomService {
	return &RoomService{
		rooms: newConcurrentRoomMap(),
		rnd:   rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

func (s *RoomService) CreateRoom(ctx context.Context, req *pb_room.CreateRoomRequest) (*pb_room.CreateRoomResponse, error) {
	if s.rooms.size() >= maxConcurrentRoom {
		return nil, status.New(codes.ResourceExhausted, "max number of room reached").Err()
	}

	roomId := s.rnd.Int31n(roomUpperLimit)
	s.rooms.storeRoom(roomId, &pb_room.Room{
		Id: roomId,
	})

	return &pb_room.CreateRoomResponse{
		RoomId: roomId,
	}, nil
}

func (s *RoomService) JoinRoom(ctx context.Context, req *pb_room.JoinRoomRequest) (*pb_room.JoinRoomResponse, error) {
	return nil, status.New(codes.Unimplemented, "not implemented").Err()
}

type concurrentRoomMap struct {
	roomMap map[int32]*pb_room.Room
	mux     *sync.RWMutex
}

func newConcurrentRoomMap() *concurrentRoomMap {
	return &concurrentRoomMap{
		roomMap: make(map[int32]*pb_room.Room),
		mux:     &sync.RWMutex{},
	}
}

func (m *concurrentRoomMap) storeRoom(key int32, room *pb_room.Room) {
	m.mux.Lock()
	defer m.mux.Unlock()

	m.roomMap[key] = room
}

func (m *concurrentRoomMap) deleteRoom(key int32) {
	m.mux.Lock()
	defer m.mux.Unlock()

	delete(m.roomMap, key)
}

func (m *concurrentRoomMap) loadRoom(key int32) (room *pb_room.Room, ok bool) {
	m.mux.RLock()
	defer m.mux.RUnlock()

	room, ok = m.roomMap[key]
	return room, ok
}

func (m *concurrentRoomMap) size() int {
	m.mux.RLock()
	defer m.mux.RUnlock()

	return len(m.roomMap)
}
