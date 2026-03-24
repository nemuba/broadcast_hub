
/**
 * Represents a DataTable component.
 * @class
 */
class Datatable {
  /**
   * Creates an instance of Datatable.
   * @param {string} table - The table element selector.
   */
  constructor(table) {
    this.table = table;
    this.target = $(table).data('target');
    this.url = $(table).data('url');
    this.init();
    this.reload();
  }

  /**
   * Initializes the DataTable component.
   */
  init() {
    this.loading();
    this.loadData();
  }

  /**
   * Reloads the DataTable component.
   */
  reload() {
    $(`${this.table} #btn-reload`).on('click', () => {
      this.init();
    });
  }

  /**
   * Loads data for the DataTable component.
   */
  loadData() {
    setTimeout(() => {
      $.get(this.url).done((data) => {
        this.render(data);
      });
    }, 1000);
  }

  /**
   * Displays a loading state for the DataTable component.
   */
  loading() {
    $(this.target).html(this.loadTemplate());
  }

  /**
   * Generates the HTML template for the loading state.
   * @returns {string} The HTML template.
   */
  loadTemplate() {
    return `
      <tr>
        <td colspan="6" class="text-center">
        <div class="d-flex justify-content-center">
          <strong>Loading...</strong>
          <div class="spinner-border spinner-border-sm mx-3 my-1" role="status" aria-hidden="true"></div>
        </div>
        </td>
      </tr>
    `;
  }

  /**
   * Renders the DataTable component with the provided data.
   * @param {Array} data - The data to render.
   */
  render(data) {
    App.Todo.renderTodos(data);
  }
}

(function () {
  this.App || (this.App = {});

  App.Datatable = Datatable
}).call(this);
