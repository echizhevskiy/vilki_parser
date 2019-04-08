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
            end
        end
    end
end