Rails.application.routes.draw do
  get 'grid/game'

  get 'grid/score'

  get 'game', to: "grid#game"
  get 'score', to: "grid#score"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
