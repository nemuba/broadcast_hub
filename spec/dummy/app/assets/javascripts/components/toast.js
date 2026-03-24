
/**
 * Represents a Toast component that displays a notification message.
 */
class Toast {
  /**
   * Adds a new toast notification.
   * @param {string} title - The title of the toast.
   * @param {string} message - The message of the toast.
   */
  static add(title, message) {
    $('.toast-container').append(this.#template(title, message));
    $('.toast-container .toast').toast('show');
    $('.toast-container .toast').on('hidden.bs.toast', function () {
      $(this).remove();
    });
  }

  /**
   * Returns the HTML template for the toast.
   * @param {string} title - The title of the toast.
   * @param {string} message - The message of the toast.
   * @return {string} - The HTML template.
   * @private
   * @static
   */
  static #template(title, message) {
    return `
      <div  class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header text-bg-primary">
          <strong class="me-auto">${title}</strong>
          <small>${new Date().toLocaleDateString()}</small>
          <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body">
          ${message}
        </div>
      </div>
    `;
  }
}

(function () {
  this.App || (this.App = {});
  this.App.Toast = Toast;
}).call(this);
