module Services
    module Dbhelper
        class DbHelperService
            class << self
                
                # получить поле date из таблицы Event
                # проверить дату на outofdate
                # удалить события со всеми ставками 
                def cleanup_out_of_date_events
                    events = Event.all

                    events.each do |event|
                        if event.date < Time.now
                            Bet.where(event_id: event.id).each { |bet| bet.destroy }
                            event.destroy
                        end
                    end
                end

                def clean_empty_ratio_bets
                    bet_id_array = []
                    bets = Bet.all
                    bets.each do |bet|
                        if bet.ratio.nil?
                            bet_id_array.push(bet.id)
                        end
                    end
                    Bet.where(id: bet_id_array).destroy_all
                end

                def clean_arbitrations
                    arbitration = Arbitration.all
                    arbitration.delete_all
                end
            end
        end
    end
end