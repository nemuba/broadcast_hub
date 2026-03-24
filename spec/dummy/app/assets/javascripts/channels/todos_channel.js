(function (global) {
  function TodoBroadcastController($) {
    this.$ = $;
    this.base = new BroadcastHubJQueryController($);
  }

  TodoBroadcastController.prototype.apply = function (payload) {
    this.base.apply(payload);
    this._syncTargetState(payload);
  };

  TodoBroadcastController.prototype._syncTargetState = function (payload) {
    if (!payload || !payload.target || payload.target.charAt(0) !== '#') {
      return;
    }

    if (!this._canAffectRowCount(payload.action)) {
      return;
    }

    var $target = this.$(payload.target);
    if ($target.length === 0) {
      return;
    }

    var count = $target.children().filter(function (_, element) {
      var elementId = element.id || '';
      return elementId !== 'empty_rows' && elementId.indexOf('more-') !== 0;
    }).length;

    this._updateTotal(payload.target, count);
    this._toggleEmptyRows($target, count);
  };

  TodoBroadcastController.prototype._canAffectRowCount = function (action) {
    return action === 'append' || action === 'prepend' || action === 'remove';
  };

  TodoBroadcastController.prototype._updateTotal = function (targetSelector, count) {
    var $total = this.$(targetSelector + '-total');

    if ($total.length === 0) {
      return;
    }

    var totalText = $total.text();

    if (/\d+\s*$/.test(totalText)) {
      $total.text(totalText.replace(/\d+\s*$/, String(count)));
    }
  };

  TodoBroadcastController.prototype._toggleEmptyRows = function ($target, count) {
    var $emptyRows = $target.children('#empty_rows').first();

    if ($emptyRows.length === 0) {
      return;
    }

    if (count === 0) {
      $emptyRows.show();
    } else {
      $emptyRows.hide();
    }
  }

  function wireTodoChannel(consumer, $) {
    var controller = new TodoBroadcastController($);
    var subscription = new BroadcastHubSubscription(consumer, controller);

    return subscription.subscribe('todo');
  }

  global.TodoChannel = global.TodoChannel || {};
  global.TodoChannel.wire = wireTodoChannel;

  if (global.App && global.App.cable && global.jQuery) {
    global.App.todo_channel = wireTodoChannel(global.App.cable, global.jQuery);
  }
})(this);
