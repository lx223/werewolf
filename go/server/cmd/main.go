package main

import (
	"context"
	"fmt"

	werewolfpb "github.com/lx223/werewolf-assistant/generated"

	"google.golang.org/grpc"
)

var ctx = context.Background()

func main() {
	conn, err := grpc.Dial("localhost:21806", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}

	c := werewolfpb.NewGameServiceClient(conn)

	createRoomRes, _ := c.CreateAndJoinRoom(ctx, &werewolfpb.CreateAndJoinRoomRequest{})
	fmt.Println(createRoomRes)

	c.UpdateGameConfig(context.Background(), &werewolfpb.UpdateGameConfigRequest{
		RoomId: createRoomRes.RoomId,
		RoleCounts: []*werewolfpb.UpdateGameConfigRequest_RoleCount{
			{
				Role:  werewolfpb.Role_SEER,
				Count: 1,
			},
			{
				Role:  werewolfpb.Role_WEREWOLF,
				Count: 4,
			},
		},
	})
}
