import * as React from 'react';
import { connect } from 'react-redux';

interface IRoomProps {
  roomNumber: string;
}

class Room extends React.Component<IRoomProps, {}> {
  public render() {
    return (
      <div>
        <h1>房间: {this.props.roomNumber}</h1>
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
)(Room);
