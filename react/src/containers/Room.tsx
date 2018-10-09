import * as React from 'react';
import { connect } from 'react-redux';
import { Box, Heading, Divider, Column } from 'gestalt';
import { RouteComponentProps } from 'react-router';
import { AppStore, ISeat } from '../reducers/app';
import Seat from '../components/Seat';
import {
  GetRoomRequest,
  GetRoomResponse,
  Room as RoomType
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
    const { seats, userId } = this.props;

    return (
      <Box>
        <Box margin={2}>
          <Heading size="xs">房间: {this.props.match.params.roomId}</Heading>
        </Box>
        <Divider />
        <Box display="flex" direction="row" wrap={true} paddingY={2}>
          {seats &&
            seats.map((seat, i) => (
              <Column span={3} key={i}>
                {this.newSeat(
                  i + 1,
                  seat.id,
                  userId,
                  false,
                  seat.userId!,
                )}
              </Column>
            ))}
        </Box>
      </Box>
    );
  }

  private newSeat = (
    no: number,
    seatId: string,
    userId: string,
    hasGameStarted: boolean,
    occupierId?: string,
  ) => {
    return (
      <Seat
        no={no}
        occupierId={occupierId}
        myUserId={userId}
        onClick={() => {
          if (!hasGameStarted) {
            takeSeat({
              userId,
              seatId
            });
          }
        }}
      />
    );
  };
}

export default connect(
  (state: AppStore) => {
    return {
      roomId: state.roomId,
      userId: state.userId,
      seats: state.seats
    } as Partial<IRoomProps>;
  },
  (dispatch: Dispatch) => {
    return {
      onGetRoomSuccess: (room: RoomType, myUserId: string) => {
        const state = room.hasGame() ? room.getGame()!.getState() : undefined;
        const seats = room.getSeatsList().map(val => {
          return {
            id: val.getId(),
            userId: val.hasUser() ? val.getUser()!.getId() : undefined
          } as ISeat;
        });
        const mySeats = room.getSeatsList().filter(s => {
          return s.hasUser() && s.getUser()!.getId() === myUserId;
        });
        const mySeatId = mySeats.length === 0 ? undefined : mySeats[0].getId();
        const role = mySeats.length === 0 ? undefined : mySeats[0].getRole();

        dispatch(
          newAction<IGetRoomSuccessPayload>(ActionType.getRoomSuccess, {
            state,
            seats,
            mySeatId,
            role
          })
        );
      },
      onGetRoomFailure: (code: Code) => {
        if (code === Code.NotFound) {
          dispatch(newAction(ActionType.getRoomFailure, {}));
        }
      }
    };
  }
)(Room);
