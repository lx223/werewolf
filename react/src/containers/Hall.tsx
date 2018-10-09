import * as React from 'react';
import { connect } from 'react-redux';
import { JoinRoomRequest, JoinRoomResponse } from '../generated/werewolf_pb';
import { GameService } from '../generated/werewolf_pb_service';
import { doGRPCRequest } from '../utils/request';
import { Code } from 'grpc-web-client/dist/Code';
import { Dispatch } from 'redux';
import { newAction, ActionType, IJoinRoomSuccessPayload } from '../actions';
import { AppStore } from '../reducers/app';
import { Button, Box, TextField, Heading, Divider } from 'gestalt';
import 'gestalt/dist/gestalt.css';
import { RouteComponentProps } from 'react-router';

interface IHallProps extends RouteComponentProps<{}> {
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
      <Box>
        <Box>
          <Heading size="xs">游戏大厅</Heading>
        </Box>
        <Divider />
        <Box>
          <TextField
            id="email"
            onChange={this.updateRoomId}
            placeholder="房间号"
            value={this.state.roomId || ''}
            type="number"
          />
        </Box>
        <Button
          text="加入房间"
          disabled={!this.state.roomId}
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
                this.navigateToRoom(this.state.roomId!);
              },
              onFailure: this.props.onJoinRoomFailure
            });
          }}
        />
        {this.props.roomId &&
          this.props.userId && (
            <Button
              text="返回上次房间"
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
                    this.navigateToRoom(this.props.roomId!);
                  },
                  onFailure: this.props.onJoinRoomFailure
                });
              }}
            />
          )}
      </Box>
    );
  }

  private updateRoomId = (args: { value: string }) => {
    this.setState({
      roomId: args.value
    });
  };

  private navigateToRoom = (roomId: string) => {
    this.props.history.push('/room/' + roomId);
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
