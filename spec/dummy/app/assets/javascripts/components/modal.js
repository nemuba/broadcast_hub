
/**
 * Represents a modal dialog.
 * @class
 */
class Modal {
  constructor(modal, title, body) {
    this.modal = new bootstrap.Modal($(modal));
    this.title = title;
    this.body = body;
  }

  /**
   * Displays the modal dialog with the specified title and form.
   * @param {string} title - The title of the modal dialog.
   * @param {string} form - The HTML form to be displayed in the modal dialog.
   */
  show(title, form) {
    $(this.title).html(title);
    $(this.body).html(form);
    this.modal.show();
  }

  close() {
    this.modal.hide();
  }
}

