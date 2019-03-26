module Services
    module Scrapers
        class BaseScraperService
            private
            
            def cleanup_previous_bets(match_kind, office)
                # все матчи с типом ("Хоккей.МХЛ", "Хоккей.ВХЛ")
                # binding.pry
                get_list_of_match_kind = Event.select("bets.*").joins(:bets).where(match_kind: match_kind, 'bets.office': office)
                # матчи, которые только что пришли после парсинга (с самой свежей датой)
                get_last_update = Event.select("bets.*").joins(:bets).where(match_kind: match_kind, 'bets.office': office, 'bets.last_update': Bet.select('max(last_update)'))
                
                get_list_of_match_kind.find_each do |match|
                    if get_last_update.include? match
                    else
                    Bet.find(match.id).destroy
                    end
                end
            end
            # поиск события в базе по имени команды
            # возвращает nill, если события нет в базе
            # возвращает event_id события, которое находится в базе
            def find_event_in_database(final_date, match_kind, home_team, guest_team)
                get_events = Event.where(match_kind: match_kind, date: final_date)
                if get_events.empty?
                    return
                elsif
                    get_events.collect do |event|
                        h = Hash.new 
                        h = { "home_team" => event.home_team, "guest_team" => event.guest_team, "id" => event.id }
                        if ( (h["home_team"] == home_team) || (h["guest_team"] == guest_team) )
                            return h["id"]
                        elsif ( (h["home_team"].include? home_team) || (h["guest_team"].include? guest_team) )
                            return h["id"]
                        elsif ( (home_team.include? h["home_team"]) || (guest_team.include? h["guest_team"]) )
                            return h["id"]
                        end
                    end
                else 
                    return
                end
            end
        end
    end
end