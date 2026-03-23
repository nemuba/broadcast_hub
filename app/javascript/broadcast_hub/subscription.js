function isBlank(value) {
  return value == null || String(value).trim() === '';
}

export default class BroadcastHubSubscription {
  constructor(consumer, controller) {
    this.consumer = consumer;
    this.controller = controller;
  }

  subscribe(resource, tenant) {
    if (isBlank(resource)) {
      throw new Error('resource is required');
    }

    const params = {
      channel: 'BroadcastHub::StreamChannel',
      resource: String(resource)
    };

    if (!isBlank(tenant)) {
      params.tenant = String(tenant);
    }

    return this.consumer.subscriptions.create(params, {
      received: this._handleReceived.bind(this)
    });
  }

  _handleReceived(payload) {
    this.controller.apply(payload);
  }
}
