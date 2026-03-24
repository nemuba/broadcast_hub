function isBlank(value) {
  return value == null || String(value).trim() === '';
}

export default class BroadcastHubJQueryController {
  constructor($, options) {
    this.$ = $;
    this.env = (options && options.env) || 'production';
  }

  apply(payload) {
    const action = payload && payload.action;
    const targetSelector = payload && payload.target;
    const content = payload && payload.content;
    const id = payload && payload.id;

    if (!this._isValidPayload(action, targetSelector, content)) {
      this._warnInvalidPayload();
      return;
    }

    const $target = this.$(targetSelector);
    const $byId = id ? this.$(`#${id}`) : this.$();

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
          const $withinTarget = $target.filter(`#${id}`).add($target.find(`#${id}`)).first();
          if ($withinTarget.length > 0) {
            $withinTarget.remove();
          }
        }
        return;
      default:
        this._warnInvalidPayload();
    }
  }

  _isValidPayload(action, targetSelector, content) {
    if (isBlank(action) || isBlank(targetSelector)) {
      return false;
    }

    if ((action === 'append' || action === 'prepend' || action === 'update') && isBlank(content)) {
      return false;
    }

    return true;
  }

  _warnInvalidPayload() {
    if (this.env === 'development' && typeof console !== 'undefined' && typeof console.warn === 'function') {
      console.warn('[BroadcastHub] Invalid payload ignored.');
    }
  }
}
