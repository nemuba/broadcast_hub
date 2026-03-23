Rails.application.routes.draw do
  mount BroadcastHub::Engine => "/broadcaster"
end
