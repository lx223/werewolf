import { Role, Game } from './generated/werewolf_pb';
import { Seat } from './entities/seat';

export interface IAction {
  type: ActionType;
  payload: any;
}

export function newAction<T>(type: ActionType, payload: T): IAction {
  return {
    type,
    payload
  };
}

export enum ActionType {
  joinRoomSuccess,
  joinRoomFailure,
  getRoomSuccess,
  getRoomFailure
}

export interface IJoinRoomSuccessPayload {
  roomId: string;
  userId: string;
}

export interface IGetRoomSuccessPayload {
  seats: Seat[];
  role?: Role;
  mySeatId?: string;
  state?: Game.State;
}
