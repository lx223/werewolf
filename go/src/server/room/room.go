package room

import (
	pb_room "server/generated/room"

	"google.golang.org/grpc/codes"

	"golang.org/x/net/context"
	"google.golang.org/grpc/status"
)

type RoomService struct{}

func NewRoomService() *RoomService {
	return &RoomService{}
}

func (s *RoomService) CreateRoom(ctx context.Context, req *pb_room.CreateRoomRequest) (*pb_room.CreateRoomResponse, error) {
	return nil, status.New(codes.Unimplemented, "not implemented").Err()
}
