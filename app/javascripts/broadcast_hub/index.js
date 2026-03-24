import BroadcastHubJQueryController from './jquery_controller';
import BroadcastHubSubscription from './subscription';

/**
 * Global object where browser runtime references are attached.
 *
 * @type {Window|typeof globalThis}
 */
const root = typeof window !== 'undefined' ? window : globalThis;

if (root) {
  root.BroadcastHubJQueryController = BroadcastHubJQueryController;
  root.BroadcastHubSubscription = BroadcastHubSubscription;

  root.BroadcastHub = root.BroadcastHub || {};
  root.BroadcastHub.JQueryController = root.BroadcastHubJQueryController;
  root.BroadcastHub.Subscription = root.BroadcastHubSubscription;
}

export { BroadcastHubJQueryController, BroadcastHubSubscription };

/**
 * Public API exported by the BroadcastHub package entrypoint.
 *
 * @type {{BroadcastHubJQueryController: typeof BroadcastHubJQueryController, BroadcastHubSubscription: typeof BroadcastHubSubscription}}
 */
export default {
  BroadcastHubJQueryController,
  BroadcastHubSubscription
};
