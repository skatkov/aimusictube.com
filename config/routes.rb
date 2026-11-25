Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "tracks#index"
  get "about", to: "pages#about"
  get "tags", to: "pages#tags"
  resources :artists, only: %i[index show]
  pull_request = "https://github.com/skatkov/aimusictube.com/compare?expand=1"
  direct(:artist_pull_request) { pull_request }
  get "artist-submissions/new", to: redirect(pull_request)
  get "watch/:youtube_id", to: "tracks#show", as: :watch, constraints: { youtube_id: /[A-Za-z0-9_-]{11}/ }
  get "tracks/:id", to: "tracks#legacy", as: :track, constraints: { id: /\d+/ }
  resources :tracks, only: [] do
    post :play, on: :member
    resource :like, only: %i[create destroy]
    resources :playlist_entries, only: :create
  end

  get "liked", to: "likes#index"
  resource :history, only: %i[show destroy], controller: "history"
  resources :playlists, only: %i[index show create destroy] do
    resources :entries, only: :destroy, controller: "playlist_entries"
  end
end
