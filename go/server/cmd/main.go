package main

import (
	"context"
	"fmt"

	werewolfpb "github.com/lx223/werewolf-assistant/generated"

	"google.golang.org/grpc"
)

func main() {
	conn, err := grpc.Dial("35.229.117.155:21806", grpc.WithInsecure())
	if err != nil {
		panic(err)
	}

	c := werewolfpb.NewGameServiceClient(conn)

	res, err := c.UpdateGameConfig(context.Background(), &werewolfpb.UpdateGameConfigRequest{
		RoomId: "115584",
		RoleCounts: []*werewolfpb.UpdateGameConfigRequest_RoleCount{
			{
				Role:  werewolfpb.Role_SEER,
				Count: 1,
			},
			{
				Role:  werewolfpb.Role_WEREWOLF,
				Count: 1,
			},
		},
	})

	if err != nil {
		panic(err)
	}
	fmt.Println(res)
}
