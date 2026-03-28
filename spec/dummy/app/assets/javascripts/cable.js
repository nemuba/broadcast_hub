// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function () {
  this.App || (this.App = {});
  App.cable = ActionCable.createConsumer();

  if (this.TodoChannel && this.TodoChannel.wire && this.jQuery && !this.App.todo_channel) {
    this.App.todo_channel = this.TodoChannel.wire(this.App.cable, this.jQuery);
  }
}).call(this);
