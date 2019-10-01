class Arbitration < ApplicationRecord
    belongs_to :event
    belongs_to :first_bet, class_name: 'Bet', foreign_key: :first_bet_id
    belongs_to :second_bet, class_name: 'Bet', foreign_key: :second_bet_id
end
