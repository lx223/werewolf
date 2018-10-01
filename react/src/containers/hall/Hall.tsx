import * as React from 'react';
import { connect } from 'react-redux';

class Hall extends React.Component<{}, {}> {
  public render() {
    return (
      <div>
        <h1>游戏大厅</h1>
        <button>创建房间</button>
        <button>加入房间</button>
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
