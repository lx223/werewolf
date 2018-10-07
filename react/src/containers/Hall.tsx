import * as React from 'react';
import { connect } from 'react-redux';
import { JoinRoomRequest, JoinRoomResponse } from '../generated/werewolf_pb';
import { GameService } from '../generated/werewolf_pb_service';
import { doGRPCRequest } from '../utils/request';
import { Code } from 'grpc-web-client/dist/Code';
import { Dispatch } from 'redux';
import { newAction, ActionType, IJoinRoomSuccessPayload } from '../actions';
import { AppStore } from '../reducers/app';

interface IHallProps {
  roomId?: string;
  userId?: string;
  onJoinRoomSuccess: (roomId: string, userId: string) => void;
  onJoinRoomFailure: (code: Code, msg: string) => void;
}

interface IHallState {
  roomId?: string;
}

class Hall extends React.Component<IHallProps, IHallState> {
  constructor(props: IHallProps) {
    super(props);
    this.state = {};
  }

  public render() {
    return (
      <div>
        <h1>游戏大厅</h1>
        <input value={this.state.roomId || ''} onChange={this.updateRoomId} />
        <button
          onClick={() => {
            const req = new JoinRoomRequest();
            req.setRoomId(this.state.roomId!);
            doGRPCRequest({
              request: req,
              rpc: GameService.JoinRoom,
              onSuccess: (res: JoinRoomResponse) => {
                this.props.onJoinRoomSuccess(
                  this.state.roomId!,
                  res.getUserId()
                );
              },
              onFailure: this.props.onJoinRoomFailure
            });
          }}
          disabled={!this.state.roomId}
        >
          加入房间
        </button>
        {this.props.roomId &&
          this.props.userId && (
            <button
              onClick={() => {
                const req = new JoinRoomRequest();
                req.setRoomId(this.props.roomId!);
                req.setUserId(this.props.userId!);
                doGRPCRequest({
                  request: req,
                  rpc: GameService.JoinRoom,
                  onSuccess: (res: JoinRoomResponse) => {
                    this.props.onJoinRoomSuccess(
                      this.props.roomId!,
                      this.props.userId!
                    );
                  },
                  onFailure: this.props.onJoinRoomFailure
                });
              }}
            >
              返回上次房间
            </button>
          )}
      </div>
    );
  }

  private updateRoomId = (elem: any) => {
    this.setState({
      roomId: elem.target.value
    });
  };
}

export default connect(
  (state: AppStore) => {
    return {
      roomId: state.roomId,
      userId: state.userId
    } as Partial<IHallProps>;
  },
  (dispatch: Dispatch) => {
    return {
      onJoinRoomSuccess: (roomId: string, userId: string) => {
        dispatch(
          newAction<IJoinRoomSuccessPayload>(ActionType.joinRoomSuccess, {
            roomId,
            userId
          })
        );
      },
      onJoinRoomFailure: () => {
        dispatch(newAction(ActionType.joinRoomFailure, {}));
      }
    };
  }
)(Hall);
