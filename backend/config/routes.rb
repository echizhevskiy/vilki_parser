Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/parimatch', to: 'parser#parse_parimatch'
  get '/leon', to: 'parser#parse_leon'
  resources :bet, only: [:index], defaults: { format: 'json'}
end
