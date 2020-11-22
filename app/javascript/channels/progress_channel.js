import consumer from "./consumer";
import CableReady from 'cable_ready';

console.log('creating subscription');
console.log(consumer);
consumer.subscriptions.create("ProgressChannel", {
  connected() {
    console.log('blurgConnect');
  },

  disconnected() {
    console.log('blurgDisconnect');
  },

  received (data) {
    console.log('blurgReceived');
    if (data.cableReady) CableReady.perform(data.operations);
  }
});
