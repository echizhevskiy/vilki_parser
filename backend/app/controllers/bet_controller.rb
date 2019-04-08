class BetController < ApplicationController
    before_action :cors_preflight_check

    def index
        bets = Bet.all
        events = Event.select("bets.*, events.*").joins(:bets)

        events_array = []
        events.each do |event|
            events_array.push({
                event_id: event.event_id,
                home_team: event.home_team,
                guest_team: event.guest_team,
                date: event.date,
                match: Event.find(event.event_id).match_kind,
                date: Event.find(event.event_id).date,
                office: event.office,
                kind: event.kind,
                ratio: event.ratio,
                attr_1: event.attr_1,
                attr_3: event.attr_3
            })   
        end

        respond_to do |format|
            format.json {render json: {:bets => events_array}, status: 200 }
        end
    end

    def cors_preflight_check
        headers['Access-Control-Allow-Origin'] = "*"
    end
end
