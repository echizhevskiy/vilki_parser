load 'base_scraper_service.rb'
module Services
    module Scrapers
        class ParimatchScraperService < BaseScraperService
            def parse(link, match_kind)
                puts "View data from parimatch"
                Headless.ly do
                    browser = Watir::Browser.new
                    browser.goto(link)
                   # binding.pry
                    #html = open(link)
                    #doc = Nokogiri::HTML(html.read)
                    doc = Nokogiri::HTML.parse(browser.html)
                    doc.encoding = 'utf-8'

                    sleep(8)
                    # для заполнения поля last_update в базе, в последствие удаление событий из таблицы Bets при парсинге матча с одной конторы
                    start_parsing_time = Time.now
                   # binding.pry
                    doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
                   #     binding.pry
                        el.css('tbody.row1.props').each do |data|
                            data['class']="row1 props processed"
                        end
                        el.css('tbody.row2.props').each do |data|
                            data['class']="row2 props processed"
                        end
                    end
                    #binding.pry
                    detail_info = false
                    doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |tbody|
                    #    binding.pry
                        tbody.css('tbody.row1, tbody.row2').each do |data|
                    #        binding.pry
                            if(detail_info == false)

                                # Получаем дату в формате 23/02 13:30 UTC +2 (при скачивании html страницы), отображается для пользователя в формате UTC +3
                                # Преобразовываем дату в формат Time 2019-02-23 14:30:00 +0300
                                date_from_parimatch = data.css('tr td')[1].text.insert(5, ' ').split(' ') # ["23/02", "13:30" ]
                                date_from_parimatch[1] = date_from_parimatch[1].to_time + 10800  # ["23/02", "2019-02-22 14:30:00 +0300" ]
                                date_from_parimatch[1] = date_from_parimatch[1].strftime("%H:%M") # [ "23/02", "14:30" ]
                                temp = date_from_parimatch[0].split('/') # ["23", "02", "14:30"]
                                temp = temp[1] + '/' + temp[0] # 02/23
                                date_from_parimatch.push(temp).shift # ["14:30" "02/23"]

                                final_date = Time.parse(date_from_parimatch[1])
                                final_date = Time.parse(date_from_parimatch[0], final_date)
                                teams = data.css('tr td a.om').children.to_s.split('<br>')
                                
                                events_from_parimatch = Event.new(date: final_date, 
                                                                home_team: teams[0],
                                                                guest_team: teams[1],
                                                                match_kind: match_kind #doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text.delete(' ')
                                                                )
                                @temp_match_kind = events_from_parimatch.match_kind
                                if find_event_in_database(events_from_parimatch.date, events_from_parimatch.match_kind, events_from_parimatch.home_team, events_from_parimatch.guest_team).nil?
                                    events_from_parimatch.save
                                    @event_id = Event.last.id
                                else
                                    @event_id = find_event_in_database(events_from_parimatch.date, events_from_parimatch.match_kind, events_from_parimatch.home_team, events_from_parimatch.guest_team)
                                end
                                detail_info = true
                            else
                                # обрабатываем детальную информацию о событии (ставки с коэффициентами)
                                # ------------  парсим дополнительные (не парсит с заглавного события) тоталы с париматча 
                                data.children.each do |tr|
                                    if (tr.search('td:nth-child(2)').search('tr:nth-child(1)').text == "Дополнительные тоталы: ")
                                        tr.search('td:nth-child(2)').search('tr:nth-child(2)').search('td:nth-child(1)').search('tr:nth-child(2)').text.split(';').each do |var|
                                            array_attributes = [] 
                                            var.split(' ').each do |get_attr|
                                                array_attributes.push(get_attr)
                                            end 
                                            # смотреть какие данные парсит, если парсит неверные данные, будет ошибка связанная с нулем
                                            if (array_attributes.size%2 == 0)
                                                total_for_event = Bet.new(event_id: @event_id,
                                                                        kind: "total", #data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                                        office: "parimatch",
                                                                        ratio: array_attributes[1],
                                                                        attr_1: Bet.last.attr_1,
                                                                        attr_3: array_attributes[0],
                                                                        last_update: start_parsing_time
                                                                        )
                                                total_for_event.save                        
                                            else
                                                total_for_event = Bet.new(event_id: @event_id,
                                                                        kind: "total", #data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                                        office: "parimatch",
                                                                        ratio: array_attributes[2],
                                                                        attr_1: array_attributes[0].gsub!(/[^0-9,.]/,''),
                                                                        attr_3: array_attributes[1],
                                                                        last_update: start_parsing_time
                                                                        )
                                                total_for_event.save                         
                                            end    
                                        end
                                    end
                                end
                                
                                
                                #-------------------------------------------------------- 

                                #------------- парсим индивидуальный тотал домашней команды с париматча
                                #get_total_team_home = data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('tr:nth-child(3)').text.split(";")
                                #puts get_total_team_home

                                # ---------------------------------------------------------------------

                                
                                #-------------- парсим индивидуальный тотал гостевой команды с париматча


                                # ---------------------------------------------------------------------
                                                
                                #total_for_event = bet.new(data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                #                          'parimatch'
                                #                        )
                                #puts data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('tr:nth-child(2)').text
                                # ----- result_ratio.each {|var| var.gsub!(/[^0-9]\./,' ')}
                                # ----- result_ratio

                                detail_info = false
                            end
                        end
                    end
                    #binding.pry
                    cleanup_previous_bets(@temp_match_kind, 'parimatch')
                    browser.close
                end
            end
        end
    end
end