Rails.application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :messages

  mount Hyperloop::Engine => '/hyperloop'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#landing_page'
  # root 'hyperloop#AppRouter'

  get '/users', to: 'hyperloop#AppRouter'

  get '/static-profile', to: 'static_page#profile'
  get '/static-profile-edit', to: 'static_page#profile-edit'
  get '/static-profile-gallery', to: 'static_page#profile-gallery'
  get '/static-profile-settings', to: 'static_page#profile-settings'

  get '/static-home', to: 'static_page#home'

  get '/static-messenger', to: 'static_page#messenger'

  get '/static-hotline', to: 'static_page#hotline'

	get '/static-layout', to: 'static_page#layout'
  get '/downloads/users/:user_id/my_avatar', to: 'downloads#serve_my_avatar'
  get '/downloads/users/:user_id/avatar', to: 'downloads#serve_user_avatar'
  get '/downloads/trips/:trip_id/avatar', to: 'downloads#serve_trip_avatar'
  get '/downloads/hotline/:hotline_id/avatar', to: 'downloads#serve_hotline_avatar'
  get '/downloads/rooms/:room_id/:user_id/avatar', to: 'downloads#serve_room_user_avatar'
  get '/downloads/user_groups/:user_group_id/avatar', to: 'downloads#serve_user_group_avatar'
	get '/downloads/users/:user_id/verification', to: 'downloads#serve_user_verification_photo'
  get '/downloads/users/:user_id/photos/:photo_id', to: 'downloads#serve_photo'
  get '/downloads/users/:user_id/photos/:photo_id/full', to: 'downloads#serve_full_photo'
	get '/downloads/users/:user_id/messages/:message_id', to: 'downloads#serve_message_photo'

  post "newsletter_subscriptions/create"

  # always at the end!
  match '*all', to: 'hyperloop#AppRouter', via: [:get], constraints: lambda { |req| !req.path.start_with?('/assets') }
end
