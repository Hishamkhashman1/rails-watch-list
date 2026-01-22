Rails.application.routes.draw do
  resources :lists, only: %i[index show new create] do
    resources :bookmarks, only: %i[new create]
  end
  resources :bookmarks, only: [:destroy]

  get "omdb/search", to: "omdb#search"
  get "omdb/details", to: "omdb#details"

  root "lists#index"
end
