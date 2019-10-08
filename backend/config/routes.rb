Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/parser', to: 'parser#call_all_parsers', as: :parser
  get '/calculate', to: 'calculate_arbitration#calculate_arbitration_total', as: :calculate
  resources :bet, only: [:index], defaults: { format: 'json'}
 # resources :arbitration, to: 'calculate_arbitration#index', defaults: { format: 'json'}
  get '/arbitration', to: 'calculate_arbitration#index'
end
