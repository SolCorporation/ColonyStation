/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { connectionLost } from './actions';
import { connectionRestored } from './actions';

const initialState = {
  // TODO: This is where round info should be.
  roundId: null,
  roundTime: null,
  roundRestartedAt: null,
  connectionLostAt: null,
  rebooting: false,
  reconnectTimer: 0,
};

export const gameReducer = (state = initialState, action) => {
  const { type, payload, meta } = action;
  if (type === 'roundrestart') {
    return {
      ...state,
      roundRestartedAt: meta.now,
      rebooting: true,
      reconnectTimer: 15,
    };
  }
  if (state.rebooting === true) {
    state.rebooting = false;
    setTimeout(() => { Byond.command('.reconnect'); }, 15000);
  }
  if (type === connectionLost.type) {
    return {
      ...state,
      connectionLostAt: meta.now,
    };
  }
  if (type === connectionRestored.type) {
    return {
      ...state,
      connectionLostAt: null,
    };
  }
  return state;
};
