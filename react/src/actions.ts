import { ISeat } from './reducers/app';
import { Role, Game } from './generated/werewolf_pb';

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
  seats: ISeat[];
  role?: Role;
  mySeatId?: string;
  state?: Game.State;
}
