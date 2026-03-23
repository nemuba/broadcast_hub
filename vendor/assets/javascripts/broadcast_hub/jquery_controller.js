(function (global) {
  function isBlank(value) {
    return value == null || String(value).trim() === '';
  }

  function BroadcastHubJQueryController($, options) {
    this.$ = $;
    this.env = (options && options.env) || 'production';
  }

  BroadcastHubJQueryController.prototype.apply = function (payload) {
    var action = payload && payload.action;
    var targetSelector = payload && payload.target;
    var content = payload && payload.content;
    var id = payload && payload.id;

    if (!this._isValidPayload(action, targetSelector, content)) {
      this._warnInvalidPayload();
      return;
    }

    var $target = this.$(targetSelector);
    var $byId = id ? this.$('#' + id) : this.$();

    switch (action) {
      case 'append':
        $target.append(content);
        return;
      case 'prepend':
        $target.prepend(content);
        return;
      case 'update':
        if ($byId.length > 0) {
          $byId.replaceWith(content);
        } else {
          $target.html(content);
        }
        return;
      case 'remove':
        if (id) {
          var $withinTarget = $target.filter('#' + id).add($target.find('#' + id)).first();
          if ($withinTarget.length > 0) {
            $withinTarget.remove();
          }
        }
        return;
      default:
        this._warnInvalidPayload();
    }
  };

  BroadcastHubJQueryController.prototype._isValidPayload = function (action, targetSelector, content) {
    if (isBlank(action) || isBlank(targetSelector)) {
      return false;
    }

    if ((action === 'append' || action === 'prepend' || action === 'update') && isBlank(content)) {
      return false;
    }

    return true;
  };

  BroadcastHubJQueryController.prototype._warnInvalidPayload = function () {
    if (this.env === 'development' && global.console && typeof global.console.warn === 'function') {
      global.console.warn('[BroadcastHub] Invalid payload ignored.');
    }
  };

  global.BroadcastHubJQueryController = BroadcastHubJQueryController;
})(this);
