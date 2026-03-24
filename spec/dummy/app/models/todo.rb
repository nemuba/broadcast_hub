class Todo < ApplicationRecord
  include BroadcastHub::Broadcaster

  belongs_to :user

  broadcast_to :todo, partial: 'todos/partials/todo', target: '#todos'

  private

  def broadcast_hub_stream_key_context_attributes
    {
      tenant_id: nil,
      current_user: user,
      session_id: nil,
      params: {}
    }
  end
end
