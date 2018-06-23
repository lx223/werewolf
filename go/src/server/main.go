package main

import (
	"fmt"
	"log"
	"net"
	proto "server/generated"

	"google.golang.org/grpc"

	"server/srv"

	flag "github.com/spf13/pflag"
)

var (
	port int
)

func init() {
	flag.IntVar(&port, "port", 21806, "host port")

	flag.Parse()
}

func main() {
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		log.Fatalf("failed to start on port %d", port)
	}

	s := grpc.NewServer()
	registerServices(s)

	if err := s.Serve(lis); err != nil {
		log.Fatal("failed to start grpc server")
	}
}

func registerServices(s *grpc.Server) {
	gameSrv := srv.NewGameService()
	proto.RegisterGameServiceServer(s, gameSrv)
}
