class Bet < ApplicationRecord
    belongs_to :event
    has_many :arbitrations
#    has_many :first_for_arbitrations, class_name: 'Bet', foreign_key: :first_bet_id
#    has_many :second_for_arbitrations, class_name: 'Bet', foreign_key: :second_bet_id
end
