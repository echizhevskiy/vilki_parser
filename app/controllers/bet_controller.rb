class BetController < ApplicationController
    def index
        bets = Bet.all

        bets_array = []
        bets.each do |bet|
            bets_array.push({
                bet_id: bet.id,
                event_id: bet.event_id,
                match: Event.find(bet.event_id).match,
                date: Event.find(bet.event_id).date,
                office: bet.office,
                kind: bet.kind,
                ratio: bet.ratio,
                attr_1: bet.attr_1,
                attr_3: bet.attr_3
            })            
        end

        respond_to do |format|
            format.json {render json: {:bets => bets_array}, status: 200 }
        end
    end
end
