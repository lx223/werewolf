import * as React from 'react';
import * as ReactDOM from 'react-dom';
import './index.css';
import registerServiceWorker from './registerServiceWorker';

import { AppReducer } from './reducers/app';

import { Provider } from 'react-redux';
import { createStore } from 'redux';
import Hall from './containers/Hall';

import { BrowserRouter, Redirect, Route, Switch } from 'react-router-dom';

const storeStorageKey = 'store_key';

const initialStore = JSON.parse(localStorage.getItem(storeStorageKey) || '{}');

const store = createStore(AppReducer, initialStore);
store.subscribe(() => {
  const currState = store.getState();
  localStorage.setItem(storeStorageKey, JSON.stringify(currState));
});

ReactDOM.render(
  <Provider store={store}>
    <BrowserRouter>
      <Switch>
        <Route exact={true} path="/" component={Hall} />
        <Redirect from="*" to="/" />
      </Switch>
    </BrowserRouter>
  </Provider>,
  document.getElementById('root') as HTMLElement
);
registerServiceWorker();
