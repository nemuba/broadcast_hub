// cSpell:words registros

class ResourceTableController {
  constructor(config) {
    this.config = this._normalizeConfig(config);
    this.target = this.config.selectors.tableBody;
    this.fields = this.config.fields;
    this.errorArgs = {
      form: this.config.selectors.form,
      errorContainer: this.config.selectors.errorContainer,
      fields: this.fields,
      fieldDomPrefix: this.config.fieldDomPrefix,
      inputSelector: this.config.inputSelector
    };
  }

  rows() {
    return $(this.target).find(this.config.rowSelector).length;
  }

  updateTotal() {
    new Tooltip();
    const count = this.rows();
    const text = this.config.messages.total.replace('%{count}', count);
    $(this.config.selectors.total).text(text);
  }

  renderList(rowsHtml) {
    $(this.target).html(rowsHtml);
    this.updateTotal();
  }

  renderInline(id, field, formHtml) {
    $(`${this.target} #${this.config.resourceName}_${id}`)
      .find(`#${this.config.resourceName}-${field}-${id}`)
      .html(formHtml);
  }

  get Modal() {
    return new Modal(
      this.config.selectors.modal,
      this.config.selectors.modalTitle,
      this.config.selectors.modalBody
    );
  }

  new(title, content) {
    this.Modal.show(title, content);
  }

  show(title, content) {
    this.Modal.show(title, content);
  }

  edit(title, content) {
    this.Modal.show(title, content);
  }

  confirmDelete(title, content) {
    this.Modal.show(title, content);
  }

  renderMore(id, moreHtml) {
    $(moreHtml).insertAfter(`#${this.config.resourceName}_${id}`);
  }

  toggleMore(id, url) {
    const moreSelector = `#${this.config.more.morePrefix}${id}`;
    const buttonSelector = `#${this.config.more.buttonPrefix}${id}`;

    if ($(this.target).find(moreSelector).length > 0) {
      $(this.target).find(moreSelector).remove();
      $(buttonSelector).toggleClass('active');
    } else {
      $.get(url);
      $(buttonSelector).toggleClass('active');
    }
  }

  renderErrors(render, errors) {
    const args = this._mergeErrorArgs({ render, errors });
    new RenderErrors(args).render();
  }

  _mergeErrorArgs(args) {
    return Object.assign({}, this.errorArgs, args);
  }

  _normalizeConfig(config) {
    if (!config || typeof config !== 'object') {
      throw new Error('[ResourceTableController] config must be an object.');
    }

    if (!config.resourceName) {
      throw new Error('[ResourceTableController] config.resourceName is required.');
    }

    if (!config.selectors || typeof config.selectors !== 'object') {
      throw new Error('[ResourceTableController] config.selectors is required.');
    }

    if (!Array.isArray(config.fields) || config.fields.length === 0) {
      throw new Error('[ResourceTableController] config.fields must be a non-empty array.');
    }

    const selectors = this._normalizeSelectors(config.selectors);
    const rowPrefix = `${config.resourceName}_`;

    return {
      resourceName: config.resourceName,
      fields: config.fields,
      selectors,
      rowSelector: config.rowSelector || `tr[id^="${config.resourceName}_"]`,
      messages: {
        total: (config.messages && config.messages.total) || 'Total de registros: %{count}'
      },
      more: {
        rowPrefix: (config.more && config.more.rowPrefix) || rowPrefix,
        morePrefix: (config.more && config.more.morePrefix) || `more-${rowPrefix}`,
        buttonPrefix: (config.more && config.more.buttonPrefix) || `btn-more-${rowPrefix}`
      },
      fieldDomPrefix: config.fieldDomPrefix || config.resourceName,
      inputSelector: config.inputSelector
    };
  }

  _normalizeSelectors(selectors) {
    const requiredKeys = [
      'tableBody',
      'emptyRows',
      'total',
      'modal',
      'modalTitle',
      'modalBody',
      'form',
      'errorContainer'
    ];

    requiredKeys.forEach((key) => {
      if (!selectors[key]) {
        throw new Error(`[ResourceTableController] config.selectors.${key} is required.`);
      }
    });

    return selectors;
  }
}
