(function (global) {
  function TodoBroadcastController($) {
    this.$ = $;
    this.base = new BroadcastHubJQueryController($);
    this._rowHighlightTimers = {};
    this._bindHighlightListener();
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
  };

  TodoBroadcastController.prototype._bindHighlightListener = function () {
    var self = this;
    var $document = this.$(document);

    $document
      .off('todo:highlight.todoChannel')
      .on('todo:highlight.todoChannel', 'tr[id^="todo_"]', function (event) {
        self._flashRow(event.currentTarget);
      });
  };

  TodoBroadcastController.prototype._flashRow = function (rowElement) {
    if (!rowElement || !rowElement.id) {
      return;
    }

    var rowId = rowElement.id;
    var activeTimer = this._rowHighlightTimers[rowId];

    if (activeTimer) {
      clearTimeout(activeTimer);
    }

    this.$(rowElement).addClass('todo-row-highlight');

    var highlightDuration = this._resolveHighlightDuration(rowElement);

    this._rowHighlightTimers[rowId] = setTimeout(function () {
      this.$(rowElement).removeClass('todo-row-highlight');
      delete this._rowHighlightTimers[rowId];
    }.bind(this), highlightDuration);
  };

  TodoBroadcastController.prototype._resolveHighlightDuration = function (rowElement) {
    var fallbackDuration = 1200;

    if (!rowElement || !global.getComputedStyle) {
      return fallbackDuration;
    }

    var computedStyle = global.getComputedStyle(rowElement);

    if (!computedStyle || !computedStyle.getPropertyValue) {
      return fallbackDuration;
    }

    var parsedDuration = this._parseDurationMs(computedStyle.getPropertyValue('--todo-highlight-duration'));

    if (parsedDuration === null) {
      return fallbackDuration;
    }

    return parsedDuration;
  };

  TodoBroadcastController.prototype._parseDurationMs = function (durationValue) {
    if (typeof durationValue !== 'string') {
      return null;
    }

    var trimmedDuration = durationValue.trim();

    if (trimmedDuration.length === 0) {
      return null;
    }

    var numericDuration;

    if (/^-?\d*\.?\d+ms$/i.test(trimmedDuration)) {
      numericDuration = parseFloat(trimmedDuration);
    } else if (/^-?\d*\.?\d+s$/i.test(trimmedDuration)) {
      numericDuration = parseFloat(trimmedDuration) * 1000;
    } else if (/^-?\d*\.?\d+$/.test(trimmedDuration)) {
      numericDuration = parseFloat(trimmedDuration);
    } else {
      return null;
    }

    if (isNaN(numericDuration) || numericDuration < 0) {
      return null;
    }

    return numericDuration;
  };

  function wireTodoChannel(consumer, $) {
    var controller = new TodoBroadcastController($);
    var subscription = new BroadcastHubSubscription(consumer, controller);

    return subscription.subscribe('todo');
  }

  global.TodoChannel = global.TodoChannel || {};
  global.TodoChannel.wire = wireTodoChannel;

  if (global.App && global.App.cable && global.jQuery && !global.App.todo_channel) {
    global.App.todo_channel = wireTodoChannel(global.App.cable, global.jQuery);
  }
})(this);
