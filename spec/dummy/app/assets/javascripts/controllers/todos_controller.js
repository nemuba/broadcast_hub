// cSpell:words todos registros

const TODO_MODAL = '#todo-modal';
const TODO_MODAL_TITLE = `${TODO_MODAL} .modal-title`;
const TODO_MODAL_BODY = `${TODO_MODAL} #modal-body`;
const TODO_MODAL_ERRORS = `${TODO_MODAL} #form-errors`;
const TODO_MODAL_FORM = `${TODO_MODAL} #todo`;
const TODO_TARGET = '#todos';
const TODO_EMPTY_ROWS = '#empty_rows';
const TODO_TOTAL = '#todos-total';

class Todo extends ResourceTableController {
  constructor(target) {
    const tableBody = target ? `#${target}` : TODO_TARGET;

    super({
      resourceName: 'todo',
      fields: ['title', 'description', 'status'],
      selectors: {
        tableBody,
        emptyRows: TODO_EMPTY_ROWS,
        total: TODO_TOTAL,
        modal: TODO_MODAL,
        modalTitle: TODO_MODAL_TITLE,
        modalBody: TODO_MODAL_BODY,
        form: TODO_MODAL_FORM,
        errorContainer: TODO_MODAL_ERRORS
      },
      messages: {
        total: 'Total de registros: %{count}'
      },
      more: {
        rowPrefix: 'todo_',
        morePrefix: 'more-todo-',
        buttonPrefix: 'btn-more-todo-'
      }
    });
  }

  renderTodos(rowsHtml) {
    this.renderList(rowsHtml);
  }

  update(targetOrId, idOrRowHtml, maybeRowHtml) {
    if (arguments.length === 3) {
      console.warn('[DEPRECATION] App.Todo.update(target, id, rowHtml) is deprecated. Use App.Todo.update(id, rowHtml).');

      const target = targetOrId;
      const id = idOrRowHtml;
      const rowHtml = maybeRowHtml;

      if (target !== this.target) {
        console.warn(`[DEPRECATION] Ignoring legacy target argument: ${target}. Using ${this.target} instead.`);
      }

      super.update(id, rowHtml);
      return;
    }

    super.update(targetOrId, idOrRowHtml);
  }
}

(function () {
  this.App || (this.App = {});
  this.App.Todo = new Todo('todos');
}).call(this);
