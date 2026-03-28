Rails.application.routes.draw do
  mount BroadcastHub::Engine => "/"
  mount ActionCable.server => "/cable"
  devise_for :users
  root "app#index"
  resources :todos do
    get "confirm_delete", on: :member
    post "highlight", on: :member
    get "inline", on: :member
    get "more", on: :member
    get "datatable", on: :collection
  end
end
