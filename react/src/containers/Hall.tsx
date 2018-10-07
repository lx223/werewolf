import * as React from 'react';

import { connect } from 'react-redux';

import { JoinRoomRequest } from '../generated/werewolf_pb';

import { GameService } from '../generated/werewolf_pb_service';

import { doGRPCRequest } from '../utils/request';

class Hall extends React.Component<{}, {}> {
  public render() {
    return (
      <div>
        <h1>游戏大厅</h1>
        <button>创建房间</button>
        <button
          onClick={() => {
            const req = new JoinRoomRequest();
            req.setRoomId('139189');
            doGRPCRequest({
              request: req,
              rpc: GameService.JoinRoom,
              onSuccess: () => {
                alert('success');
              },
              onFailure: () => {
                alert('failure');
              }
            });
          }}
        >
          加入房间
        </button>
      </div>
    );
  }
}

export default connect(
  () => {
    return;
  },
  () => {
    return;
  }
)(Hall);
