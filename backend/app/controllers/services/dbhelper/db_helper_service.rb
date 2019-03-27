module Services
    module Dbhelper
        class DbHelperService
            class << self

                # получить поле date из таблицы Event
                # проверить дату на outofdate
                # удалить события со всеми ставками 
                def cleanup_out_of_date_events
                    events = Event.select('bets.*, events.*').joins(:bets)

                    events.each do |event|
                        if event.date < Time.now
                            if event.destroy
                                Bet.where(event_id: event.id).each do |bet|
                                    bet.destroy
                                end

                                puts "#{event.date}" + "#{event.id}" 
                                puts "-----------------Out of date event has been deleted------------------"
                            end
                        end
                    end
                end

            end
        end
    end
end