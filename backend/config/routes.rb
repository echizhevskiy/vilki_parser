Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/parser', to: 'parser#call_all_parsers'
  resources :bet, only: [:index], defaults: { format: 'json'}
end
