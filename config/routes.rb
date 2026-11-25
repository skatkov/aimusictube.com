Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "tracks#index"
  get "about", to: "pages#about"
  get "tags", to: "pages#tags"
  resources :artists, only: %i[index show]
  repository = "https://github.com/skatkov/aimusictube.com"
  catalog_editor = "#{repository}/edit/main/db/catalog.json"
  direct(:source_repository) { repository }
  direct(:artist_catalog_edit) { catalog_editor }
  get "artist-submissions/new", to: redirect(catalog_editor)
  get "watch/:youtube_id", to: "tracks#show", as: :watch, constraints: { youtube_id: /[A-Za-z0-9_-]{11}/ }
  resolve("Track") { |track, options| route_for(:watch, track.youtube_id, options) }
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
