# frozen_string_literal: true

BroadcastHub.configure do |config|
  config.allowed_resources = %w[todo]

  config.authorize_scope = lambda do |context|
    context.current_user.present?
  end

  config.stream_key_resolver = lambda do |context|
    user = context.respond_to?(:current_user) ? context.current_user : nil

    if user.present?
      "resource:#{context.resource_name}:user:#{user.id}"
    else
      "resource:#{context.resource_name}"
    end
  end
end
