(function (global) {
  function isBlank(value) {
    return value == null || String(value).trim() === '';
  }

  function BroadcastHubSubscription(consumer, controller) {
    this.consumer = consumer;
    this.controller = controller;
  }

  BroadcastHubSubscription.prototype.subscribe = function (resource, tenant) {
    if (isBlank(resource)) {
      throw new Error('resource is required');
    }

    var params = {
      channel: 'BroadcastHub::StreamChannel',
      resource: String(resource)
    };

    if (!isBlank(tenant)) {
      params.tenant = String(tenant);
    }

    return this.consumer.subscriptions.create(params, {
      received: this._handleReceived.bind(this)
    });
  };

  BroadcastHubSubscription.prototype._handleReceived = function (payload) {
    this.controller.apply(payload);
  };

  global.BroadcastHubSubscription = BroadcastHubSubscription;
})(this);
