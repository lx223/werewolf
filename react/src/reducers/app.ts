import { Role, Game } from '../generated/werewolf_pb';
import {
  IAction,
  ActionType,
  IJoinRoomSuccessPayload,
  IGetRoomSuccessPayload
} from '../actions';
import { Seat } from 'src/entities/seat';

export class AppStore {
  public roomId?: string;
  public userId?: string;
  public seats?: Seat[];
  public state?: Game.State;
  public myRole?: Role;
  public mySeatId?: string;
}

export function AppReducer(currentState: AppStore, action: IAction): AppStore {
  if (action.type === ActionType.joinRoomSuccess) {
    const payload = action.payload as IJoinRoomSuccessPayload;
    return {
      ...currentState,
      roomId: payload.roomId,
      userId: payload.userId
    };
  }

  if (action.type === ActionType.getRoomSuccess) {
    const payload = action.payload as IGetRoomSuccessPayload;
    return {
      ...currentState,
      state: payload.state,
      myRole: payload.role,
      mySeatId: payload.mySeatId,
      seats: payload.seats
    };
  }

  if (
    action.type === ActionType.joinRoomFailure ||
    action.type === ActionType.getRoomFailure
  ) {
    return {};
  }

  return currentState;
}
