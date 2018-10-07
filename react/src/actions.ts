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
  joinRoomFailure
}

export interface IJoinRoomSuccessPayload {
  roomId: string;
  userId: string;
}
