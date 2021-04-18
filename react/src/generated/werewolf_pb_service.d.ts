// package: werewolf
// file: werewolf.proto

import * as werewolf_pb from "./werewolf_pb";
import {grpc} from "grpc-web-client";

type GameServiceCreateAndJoinRoom = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.CreateAndJoinRoomRequest;
  readonly responseType: typeof werewolf_pb.CreateAndJoinRoomResponse;
};

type GameServiceUpdateGameConfig = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.UpdateGameConfigRequest;
  readonly responseType: typeof werewolf_pb.UpdateGameConfigResponse;
};

type GameServiceJoinRoom = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.JoinRoomRequest;
  readonly responseType: typeof werewolf_pb.JoinRoomResponse;
};

type GameServiceGetRoom = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.GetRoomRequest;
  readonly responseType: typeof werewolf_pb.GetRoomResponse;
};

type GameServiceTakeSeat = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.TakeSeatRequest;
  readonly responseType: typeof werewolf_pb.TakeSeatResponse;
};

type GameServiceCheckRole = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.CheckRoleRequest;
  readonly responseType: typeof werewolf_pb.CheckRoleResponse;
};

type GameServiceReassignRoles = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.ReassignRolesRequest;
  readonly responseType: typeof werewolf_pb.ReassignRolesResponse;
};

type GameServiceVacateSeat = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.VacateSeatRequest;
  readonly responseType: typeof werewolf_pb.VacateSeatResponse;
};

type GameServiceStartGame = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.StartGameRequest;
  readonly responseType: typeof werewolf_pb.StartGameResponse;
};

type GameServiceTakeAction = {
  readonly methodName: string;
  readonly service: typeof GameService;
  readonly requestStream: false;
  readonly responseStream: false;
  readonly requestType: typeof werewolf_pb.TakeActionRequest;
  readonly responseType: typeof werewolf_pb.TakeActionResponse;
};

export class GameService {
  static readonly serviceName: string;
  static readonly CreateAndJoinRoom: GameServiceCreateAndJoinRoom;
  static readonly UpdateGameConfig: GameServiceUpdateGameConfig;
  static readonly JoinRoom: GameServiceJoinRoom;
  static readonly GetRoom: GameServiceGetRoom;
  static readonly TakeSeat: GameServiceTakeSeat;
  static readonly CheckRole: GameServiceCheckRole;
  static readonly ReassignRoles: GameServiceReassignRoles;
  static readonly VacateSeat: GameServiceVacateSeat;
  static readonly StartGame: GameServiceStartGame;
  static readonly TakeAction: GameServiceTakeAction;
}

export type ServiceError = { message: string, code: number; metadata: grpc.Metadata }
export type Status = { details: string, code: number; metadata: grpc.Metadata }
export type ServiceClientOptions = { transport: grpc.TransportConstructor; debug?: boolean }

interface ResponseStream<T> {
  cancel(): void;
  on(type: 'data', handler: (message: T) => void): ResponseStream<T>;
  on(type: 'end', handler: () => void): ResponseStream<T>;
  on(type: 'status', handler: (status: Status) => void): ResponseStream<T>;
}

export class GameServiceClient {
  readonly serviceHost: string;

  constructor(serviceHost: string, options?: ServiceClientOptions);
  createAndJoinRoom(
    requestMessage: werewolf_pb.CreateAndJoinRoomRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.CreateAndJoinRoomResponse|null) => void
  ): void;
  createAndJoinRoom(
    requestMessage: werewolf_pb.CreateAndJoinRoomRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.CreateAndJoinRoomResponse|null) => void
  ): void;
  updateGameConfig(
    requestMessage: werewolf_pb.UpdateGameConfigRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.UpdateGameConfigResponse|null) => void
  ): void;
  updateGameConfig(
    requestMessage: werewolf_pb.UpdateGameConfigRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.UpdateGameConfigResponse|null) => void
  ): void;
  joinRoom(
    requestMessage: werewolf_pb.JoinRoomRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.JoinRoomResponse|null) => void
  ): void;
  joinRoom(
    requestMessage: werewolf_pb.JoinRoomRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.JoinRoomResponse|null) => void
  ): void;
  getRoom(
    requestMessage: werewolf_pb.GetRoomRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.GetRoomResponse|null) => void
  ): void;
  getRoom(
    requestMessage: werewolf_pb.GetRoomRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.GetRoomResponse|null) => void
  ): void;
  takeSeat(
    requestMessage: werewolf_pb.TakeSeatRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.TakeSeatResponse|null) => void
  ): void;
  takeSeat(
    requestMessage: werewolf_pb.TakeSeatRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.TakeSeatResponse|null) => void
  ): void;
  checkRole(
    requestMessage: werewolf_pb.CheckRoleRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.CheckRoleResponse|null) => void
  ): void;
  checkRole(
    requestMessage: werewolf_pb.CheckRoleRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.CheckRoleResponse|null) => void
  ): void;
  reassignRoles(
    requestMessage: werewolf_pb.ReassignRolesRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.ReassignRolesResponse|null) => void
  ): void;
  reassignRoles(
    requestMessage: werewolf_pb.ReassignRolesRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.ReassignRolesResponse|null) => void
  ): void;
  vacateSeat(
    requestMessage: werewolf_pb.VacateSeatRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.VacateSeatResponse|null) => void
  ): void;
  vacateSeat(
    requestMessage: werewolf_pb.VacateSeatRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.VacateSeatResponse|null) => void
  ): void;
  startGame(
    requestMessage: werewolf_pb.StartGameRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.StartGameResponse|null) => void
  ): void;
  startGame(
    requestMessage: werewolf_pb.StartGameRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.StartGameResponse|null) => void
  ): void;
  takeAction(
    requestMessage: werewolf_pb.TakeActionRequest,
    metadata: grpc.Metadata,
    callback: (error: ServiceError, responseMessage: werewolf_pb.TakeActionResponse|null) => void
  ): void;
  takeAction(
    requestMessage: werewolf_pb.TakeActionRequest,
    callback: (error: ServiceError, responseMessage: werewolf_pb.TakeActionResponse|null) => void
  ): void;
}

