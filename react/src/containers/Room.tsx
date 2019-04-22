import * as React from 'react';
import { connect } from 'react-redux';
import { Box, Heading, Divider, Column, Button } from 'gestalt';
import { RouteComponentProps } from 'react-router';
import { AppStore } from '../reducers/app';
import {
  GetRoomRequest,
  GetRoomResponse,
  Room as RoomType,
  Role
} from '../generated/werewolf_pb';
import { doGRPCRequest, takeSeat } from '../utils/request';
import { GameService } from '../generated/werewolf_pb_service';
import { Dispatch } from 'redux';
import { ActionType, newAction, IGetRoomSuccessPayload } from '../actions';
import { Code } from 'grpc-web-client/dist/Code';
import 'gestalt/dist/gestalt.css';
import RevealRoleModal from 'src/components/RevealRoleModal';
import { Seat as DbSeat } from 'src/entities/seat';
import Seat from 'src/components/Seat';

interface IRoomProps extends RouteComponentProps<{ roomId: string }> {
  roomId: string;
  userId: string;
  seats?: DbSeat[];
  chosenRole: Role;

  onGetRoomSuccess: (room: RoomType) => void;
  onGetRoomFailure: (code: Code) => void;
}

interface IRoomState {
  showRoleModal: boolean;
  hasSeenRole: boolean;
}

const defaultRoomState: IRoomState = {
  showRoleModal: false,
  hasSeenRole: false
};

class Room extends React.Component<IRoomProps, IRoomState> {
  private intervalId: NodeJS.Timer;

  constructor(props: IRoomProps) {
    super(props);

    this.state = defaultRoomState;
  }

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
    const { seats, userId, chosenRole } = this.props;

    return (
      <Box>
        <Box margin={2}>
          <Heading size="xs">房间: {this.props.match.params.roomId}</Heading>
        </Box>
        <Divider />
        <Box display="flex" direction="row" wrap={true} paddingY={2}>
          {seats &&
            seats.map((s, i) => (
              <Column span={3} key={i}>
                {this.newSeat(i + 1, s.id, userId, false, s.occupierUserId)}
              </Column>
            ))}
        </Box>

        <Box shape="rounded" display="flex" direction="row">
          <Box column={6} paddingX={1}>
            <Button
              text="查看身份"
              color={this.state.hasSeenRole ? 'white' : 'red'}
              onClick={() => {
                this.setState({ showRoleModal: !this.state.showRoleModal });
              }}
            />
          </Box>
          <Box column={6} paddingX={1}>
            <Button text="使用技能" />
          </Box>
        </Box>

        {this.state.showRoleModal && (
          <RevealRoleModal
            choseRole={chosenRole}
            onDismiss={() => {
              this.setState({ hasSeenRole: true, showRoleModal: false });
            }}
          />
        )}
      </Box>
    );
  }

  private newSeat = (
    no: number,
    seatId: string,
    userId: string,
    hasGameStarted: boolean,
    occupierId?: string
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
      seats: state.seats,
      chosenRole: state.myRole
    } as Partial<IRoomProps>;
  },
  (dispatch: Dispatch) => {
    return {
      onGetRoomSuccess: (room: RoomType, myUserId: string) => {
        const state = room.hasGame() ? room.getGame()!.getState() : undefined;
        const seats = room.getSeatsList().map(pbSeat => {
          return new DbSeat(pbSeat);
        });
        const mySeats = seats.filter(s => {
          return s.occupierUserId === myUserId;
        });
        const mySeatId = mySeats.length === 0 ? undefined : mySeats[0].id;
        const role = mySeats.length === 0 ? undefined : mySeats[0].assignedRole;

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
