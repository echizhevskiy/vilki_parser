Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/parser', to: 'parser#call_all_parsers'
  get '/calculate', to: 'calculate_arbitration#calculate_arbitration_total'
  resources :bet, only: [:index], defaults: { format: 'json'}
end
