package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	proto "server/generated"

	"google.golang.org/grpc"

	"server/srv"

	"github.com/improbable-eng/grpc-web/go/grpcweb"
	flag "github.com/spf13/pflag"
)

var (
	port        int
	grpcWebPort int
)

func init() {
	flag.IntVar(&port, "port", 21806, "host port")
	flag.IntVar(&grpcWebPort, "grpc_web_port", 21807, "")

	flag.Parse()
}

func main() {
	errChan := make(chan error, 1)

	s := grpc.NewServer()
	registerServices(s)

	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		log.Fatalf("failed to start on port %d", port)
	}

	go func() {
		log.Printf("Start serving gRPC requests at :%d", port)
		errChan <- s.Serve(lis)
	}()

	go func() {
		log.Printf("Start serving gRPC requests at :%d", grpcWebPort)
		errChan <- http.ListenAndServe(fmt.Sprintf(":%d", grpcWebPort), grpcweb.WrapServer(s))
	}()

	for {
		if err := <-errChan; err != nil {
			log.Fatalf("server shut down with error %v", err)
		}

		log.Println("server shut down successfully")
	}
}

func registerServices(s *grpc.Server) {
	gameSrv := srv.NewGameService()
	proto.RegisterGameServiceServer(s, gameSrv)
}
