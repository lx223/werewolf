import * as React from 'react';
import * as ReactDOM from 'react-dom';
import './index.css';
import registerServiceWorker from './registerServiceWorker';

import { AppReducer } from './reducers/app';

import { Provider } from 'react-redux';
import { createStore } from 'redux';
import Hall from './containers/hall/Hall';

import { BrowserRouter, Redirect, Route, Switch } from 'react-router-dom';
import Room from './containers/room/Room';

import Config from './containers/config/Config';

const store = createStore(AppReducer, {});

ReactDOM.render(
  <Provider store={store}>
    <BrowserRouter>
      <Switch>
        <Route exact={true} path="/" component={Hall} />
        <Route exact={true} path="/rooms/:roomId" component={Room} />
        <Route exact={true} path="/rooms/:roomId/config" component={Config} />
        <Redirect from="*" to="/" />
      </Switch>
    </BrowserRouter>
  </Provider>,
  document.getElementById('root') as HTMLElement
);
registerServiceWorker();
