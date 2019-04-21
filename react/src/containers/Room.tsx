import * as React from 'react';
import { connect } from 'react-redux';
<<<<<<< HEAD

interface IRoomProps {
  roomNumber: string;
}

class Room extends React.Component<IRoomProps, {}> {
  public render() {
    return (
      <div>
        <h1>房间: {this.props.roomNumber}</h1>
      </div>
=======
import { Box, Heading, Divider, Column } from 'gestalt';
import { RouteComponentProps } from 'react-router';
import { AppStore, ISeat } from '../reducers/app';
import Seat, { SeatColour } from '../components/Seat';
import {
  GetRoomRequest,
  GetRoomResponse,
  Room as RoomType,
  Game
} from '../generated/werewolf_pb';
import { doGRPCRequest, takeSeat } from '../utils/request';
import { GameService } from '../generated/werewolf_pb_service';
import { Dispatch } from 'redux';
import { ActionType, newAction, IGetRoomSuccessPayload } from '../actions';
import { Code } from 'grpc-web-client/dist/Code';
import 'gestalt/dist/gestalt.css';

interface IRoomProps extends RouteComponentProps<{ roomId: string }> {
  roomId: string;
  userId: string;
  seats?: ISeat[];
  state?: Game.State;
  game?: Game;

  onGetRoomSuccess: (room: RoomType) => void;
  onGetRoomFailure: (code: Code) => void;
}

class Room extends React.Component<IRoomProps, {}> {
  private intervalId: NodeJS.Timer;

  public componentDidMount() {
    this.intervalId = setInterval(() => {
      const req = new GetRoomRequest();
      req.setRoomId(this.props.roomId);
      doGRPCRequest({
        request: req,
        rpc: GameService.GetRoom,
        onSuccess: (res: GetRoomResponse) => {
          this.props.onGetRoomSuccess(res.getRoom()!);
        },
        onFailure: (code: Code) => {
          this.props.onGetRoomFailure(code);
          this.props.history.replace('/');
        }
      });
    }, 2000);
  }

  public componentWillUnmount() {
    clearInterval(this.intervalId);
  }

  public render() {
    const { seats, userId, roomId } = this.props;

    return (
      <Box>
        <Box margin={2}>
          <Heading size="xs">房间: {this.props.match.params.roomId}</Heading>
        </Box>
        <Divider />
        <Box display="flex" direction="row" wrap={true} paddingY={2}>
          {seats &&
            seats.map((_, i) => (
              <Column span={3} key={i}>
                {this.newSeat(i + 1, seats[i], roomId, userId)}
              </Column>
            ))}
        </Box>
      </Box>
>>>>>>> a2f6487... Use new go mod system
    );
  }

  private newSeat = (
    no: number,
    seat: ISeat,
    roomId: string,
    userId: string
  ) => {
    const seatColour =
      seat.userId === userId
        ? SeatColour.takenByMe
        : !!seat.userId
          ? SeatColour.taken
          : SeatColour.vacant;
    return (
      <Seat
        no={no}
        colour={seatColour}
        onClick={() => {
          const hasGameStarted = !!this.props.state;
          if (!hasGameStarted) {
            takeSeat({
              userId,
              seatId: seat.id
            });
          }
        }}
      />
    );
  };
}

export default connect(
<<<<<<< HEAD
  () => {
    return;
=======
  (state: AppStore) => {
    return {
      roomId: state.roomId,
      userId: state.userId,
      seats: state.seats,
      state: state.state
    } as Partial<IRoomProps>;
>>>>>>> a2f6487... Use new go mod system
  },
  () => {
    return;
  }
)(Room);
