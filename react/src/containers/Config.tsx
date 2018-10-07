import * as React from 'react';
import { connect } from 'react-redux';

class Config extends React.Component<{}, {}> {
  public render() {
    return (
      <div>
        <h1>配置设置</h1>
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
)(Config);
