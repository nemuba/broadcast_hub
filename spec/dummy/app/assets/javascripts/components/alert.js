const CONTAINER = '#alert-container';

/**
 * Alert component
 *
 * Usage:
 *
 * Alert.add('Your message here', 'success')
 */
class Alert {
  /**
   * Add a new alert to the container
   * @static
   * @public
   * @param {string} message
   * @param {string} type
   * @return {void}
   */
  static add(message, type = 'success') {
    $(CONTAINER).append(this.#template(message, type))

    setTimeout(() => {
      $(`${CONTAINER} .alert`).alert('close')
    }, 3000)
  }

  /**
   * Alert template
   * @static
   * @private
   * @param {string} message
   * @param {string} type
   * @return {string}
   */
  static #template(message, type) {
    return `
      <div class="alert alert-${type} alert-dismissible fade show" role="alert">
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      </div>
    `
  }
}
