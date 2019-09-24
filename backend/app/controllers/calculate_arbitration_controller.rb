class CalculateArbitrationController < ApplicationController
    
    def calculate_arbitration_total
        Services::Dbhelper::DbHelperService.clean_empty_ratio_bets

        Event.all.each do |event|
            Bet.pluck(:office).uniq.each do |office1|
                Bet.where(kind: 'total', event_id: event.id).each do |bet1|
                    if office1 == bet1.office
                        total1 = bet1.attr_1
                        ratio1 = bet1.ratio
                        bet_type1 = bet1.attr_3
                        
                        Bet.pluck(:office).uniq.each do |office2|
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
                                                puts("---------------------Beggining of arbitration------------------------------------")
                                                puts("Ratio is #{k}")
                                                puts("Office: #{office1}, Total: #{total1}, Type of total: #{bet_type1}, Ratio: #{ratio1}")
                                                puts("Office: #{office2}, Total: #{total2}, Type of total: #{bet_type2}, Ratio: #{ratio2}")
                                                puts("-----------------------End of arbitration------------------------------------")
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
