class CalculateArbitrationController < ApplicationController
    
    def index
        @arbitration = Arbitration.all
        # arbitration_array = []
        # Arbitration.all.each do |arbitration|
        #     arbitration_array.push({
        #         home_team: arbitration.event.home_team,
        #         guest_team: arbitration.event.guest_team,
        #         date: arbitration.event.date,
        #         match_kind: arbitration.event.match_kind,
        #         office_1: arbitration.first_bet.office,
        #         ratio_1: arbitration.first_bet.ratio,
        #         attr_1_1: arbitration.first_bet.attr_1,
        #         attr_3_1: arbitration.first_bet.attr_3,
        #         office_2: arbitration.second_bet.office,
        #         ratio_2: arbitration.second_bet.ratio,
        #         attr_1_2: arbitration.second_bet.attr_1,
        #         attr_3_2: arbitration.second_bet.attr_3
        #     })
        # end

        # respond_to do |format|
        #     format.json {render json: {:arbitrations => arbitration_array}, status: 200 }
        # end
    end

    def calculate_arbitration_total
        Services::Dbhelper::DbHelperService.clean_empty_ratio_bets
        Services::Dbhelper::DbHelperService.clean_arbitrations

        Event.all.each do |event|
            Bet.pluck(:office).uniq.each do |office1|
                Bet.where(kind: 'total', event_id: event.id).each do |bet1|
                    if office1 == bet1.office
                        total1 = bet1.attr_1
                        ratio1 = bet1.ratio
                        bet_type1 = bet1.attr_3
                        
                        Bet.pluck(:office).uniq.drop(1).each do |office2|
                            if office2 == office1
                                puts ''
                            else
                                Bet.where(kind: 'total', event_id: event.id).each do |bet2|
                                    if office2 == bet2.office
                                        total2 = bet2.attr_1
                                        ratio2 = bet2.ratio
                                        bet_type2 = bet2.attr_3
                                        
                                        if (total1 == total2) && (bet_type1 != bet_type2)
                                            k = 1/ratio1 + 1/ratio2
                                            
                                            if k < 1
                                                events_and_bets = Event.select("events.*, bets.*").joins(:bets).where(id: bet1.event_id).first

                                                arbitration = Arbitration.new(event_id: bet2.event_id, first_bet_id: bet1.id, second_bet_id: bet2.id, ratio: k)
                                                arbitration.save
                                                puts("---------------------Beggining of arbitration------------------------------------")
                                                puts("Ratio is #{k}")
                                                puts("Office: #{office1}, Total: #{total1}, Type of total: #{bet_type1}, Ratio: #{ratio1}, Match: #{events_and_bets.home_team} - #{events_and_bets.guest_team}, Date: #{events_and_bets.date}, Match kind: #{events_and_bets.match_kind}")
                                                puts("Office: #{office2}, Total: #{total2}, Type of total: #{bet_type2}, Ratio: #{ratio2}, Match: #{events_and_bets.home_team} - #{events_and_bets.guest_team}, Date: #{events_and_bets.date}, Match kind: #{events_and_bets.match_kind}")
                                                puts("-----------------------End of arbitration------------------------------------")

                                                # To display infortmation use next queries
                                                # Arbitration.each {|ar| puts ar.first_bet, ar.second_bet, ar.event}
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
