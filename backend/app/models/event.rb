class Event < ApplicationRecord
    has_many :bets, dependent: :destroy
    has_many :arbitrations
#    has_many :first_for_arbitrations, through: :bets
#    has_many :second_for_arbitrations, through: :bets
end
