
/**
 * Represents a class for rendering errors.
 * @class
 */
class RenderErrors {
  constructor(args) {
    this.form = args.form;
    this.errorContainer = args.errorContainer;
    this.fields = args.fields;
    this.errors = args.errors;
    this.renderHTML = args.render;
    this.fieldDomPrefix = args.fieldDomPrefix || this._inferFieldDomPrefix(args.form);
    this.inputSelector = args.inputSelector;
    this.init();
  }

  /**
   * Initializes the errors.
   * @public
   */
  init() {
    this.list = this._normalizeErrorsList(this.errors);
  }

  /**
   * Renders the errors on the error container.
   * @public
   */
  render() {
    $(this.errorContainer).html(this.renderHTML);

    this._formFocus();
  }

  /**
   * Sets focus on the first field with an error and adds error classes to the corresponding fields.
   * @private
   */
  _formFocus() {
    // Add focus to the first field with an error
    this._focusFieldError();

    // Remove class of error from all list
    this._removeInvalidClass();

    // Add class of error to list with errors
    this._addInvalidClass();
  }

  /**
   * Sets focus on the first field with an error.
   * @private
   */
  _focusFieldError() {
    const firstField = this.list.at(0);

    if (!firstField) {
      return;
    }

    this._findField(firstField).focus();
  }

  /**
   * Removes the class of error from all fields.
   * @private
   */
  _removeInvalidClass() {
    this.fields.forEach((field) => {
      this._findField(field).removeClass('is-invalid');
    });
  }

  /**
   * Adds the class of error to
   * @private
   */
  _addInvalidClass() {
    this.list.forEach((field) => {
      this._findField(field).addClass('is-invalid');
    });
  }

  _findField(field) {
    return $(`${this.form}`).find(this._resolveFieldSelector(field));
  }

  _resolveFieldSelector(field) {
    if (typeof this.inputSelector === 'function') {
      return this.inputSelector(field);
    }

    return `#${this.fieldDomPrefix}_${field}`;
  }

  _inferFieldDomPrefix(formSelector) {
    const elementId = $(formSelector).attr('id');

    if (elementId && elementId.length > 0) {
      return elementId;
    }

    return 'resource';
  }

  _normalizeErrorsList(errors) {
    if (Array.isArray(errors)) {
      return errors.map((field) => String(field).trim()).filter((field) => field.length > 0);
    }

    if (errors == null) {
      return [];
    }

    const normalized = String(errors).replace(/&quot;/g, '"').trim();

    if (normalized.length === 0) {
      return [];
    }

    if (normalized.startsWith('[') || normalized.startsWith('{')) {
      try {
        const parsed = JSON.parse(normalized);

        if (Array.isArray(parsed)) {
          return parsed.map((field) => String(field).trim()).filter((field) => field.length > 0);
        }

        if (parsed && typeof parsed === 'object') {
          return Object.keys(parsed);
        }
      } catch (_error) {
        if (typeof console !== 'undefined' && typeof console.warn === 'function') {
          console.warn('[RenderErrors] Failed to parse errors payload. Falling back to empty error list.');
        }

        return [];
      }
    }

    if (normalized.includes(',')) {
      return normalized
        .split(',')
        .map((field) => field.replace(/[\[\]"]/g, '').trim())
        .filter((field) => field.length > 0);
    }

    const singleField = normalized.replace(/[\[\]"]/g, '').trim();
    return singleField.length > 0 ? [singleField] : [];
  }
}
