require 'open-uri'
require 'nokogiri'
require 'date'
require 'watir'
require 'webdrivers'

class ParserController < ApplicationController

    #parser for parimatch
    def parse_parimatch
        html = open('https://pm.by/sport/khokkejj/vkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'

        # для заполнения поля last_update в базе, в последствие удаление событий из таблицы Bets при парсинге матча с одной конторы
        start_parsing_time = Time.now

        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
            el.css('tbody.row1.props').each do |data|
                data['class']="row1 props processed"
            end
            el.css('tbody.row2.props').each do |data|
                data['class']="row2 props processed"
            end
        end
        
        detail_info = false
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |tbody|
            tbody.css('tbody.row1, tbody.row2').each do |data|
                if(detail_info == false)

                    # Получаем дату в формате 23/02 13:30 UTC +2 (при скачивании html страницы), отображается для пользователя в формате UTC +3
                    # Преобразовываем дату в формат Time 2019-02-23 14:30:00 +0300
                    date_from_parimatch = data.css('tr td')[1].text.insert(5, ' ').split(' ') # ["23/02", "13:30" ]
                    date_from_parimatch[1] = date_from_parimatch[1].to_time + 14400  # ["23/02", "2019-02-22 14:30:00 +0300" ]
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
                                                      match_kind: doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text.delete(' ')
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
                    data.search('tr:nth-child(13)').search('td:nth-child(2)').search('tr:nth-child(2)').search('td:nth-child(1)').search('tr:nth-child(2)').text.split(';').each do |var|
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
    end

    #parser for leon bet
    def parse_leon
        browser = Watir::Browser.new
        
        start_parsing_time = Time.now
        event_data = []
        bet_data = []
        browser.goto('https://www.leon.ru/events/IceHockey/562949953443953-Russia-MHL-Playoffs')

        browser.is(class: /material-icons keyboard_arrow_down/).each do |icon|
            icon.click
            sleep(0.4)

            doc = Nokogiri::HTML(browser.html)
            doc.encoding = 'utf-8'

            #достаю только раскрытые блоки в цикле, все остальные игнорируются
            doc.css('div.content div.fon div.body div.main span').each do |main|
                main.css('li.expanded').each do |data|
                        time = data.search('div:nth-child(1)').search('div:nth-child(1)').search('span:nth-child(1)').search('div:nth-child(1)').text
                        date = data.search('div:nth-child(1)').search('div:nth-child(1)').search('span:nth-child(1)').search('div:nth-child(2)').text
                        final_time = Time.parse time + " " + date
                        final_time = final_time + 10800
                        teams = data.search('div:nth-child(1)').search('div:nth-child(2)').search('div:nth-child(1)').search('a:nth-child(1)').search('span:nth-child(1)').text.split(' - ')

                        event_data = Event.new(
                                            date: final_time,
                                            home_team: teams[0],
                                            guest_team: teams[1],
                                            match_kind: main.css('div.head-title div.middle a').text.strip.delete(' ').gsub(/,.*/, '').gsub(/-.*-/, '.')                              
                                            )
                        @temp_match_kind = event_data.match_kind
                        if find_event_in_database(event_data.date, event_data.match_kind, event_data.home_team, event_data.guest_team).nil?
                            event_data.save
                            @event_id = Event.last.id
                        else
                            @event_id = find_event_in_database(event_data.date, event_data.match_kind, event_data.home_team, event_data.guest_team)
                        end
                    #ищем нужную секцию с тоталом
                    data.search('div:nth-child(2)').search('ul:nth-child(1)').search('li:nth-child(2)').search('div:nth-child(4)').search('ul:nth-child(2)').css('li').each do |li| 
                        get_total_with_min_max = li.search('span:nth-child(1)').text.split(' ')
                        bet_data = Bet.new(
                                        event_id: @event_id,
                                        kind: "total",
                                        office: "leon",
                                        ratio: li.search('span:nth-child(2)').text, 
                                        attr_1: get_total_with_min_max[1].gsub!(/[^0-9,.]/,''),
                                        attr_3: get_total_with_min_max[0].mb_chars.downcase.to_s,
                                        last_update: start_parsing_time                                  
                                        )
                        bet_data.save
                    end  
                end
            end            
        end
        browser.close
        cleanup_previous_bets(@temp_match_kind, 'leon')
    end


    private
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

    # удаляет все ставки, кроме самых свежих по полю "last_update" для определенного типа матча "Хоккей.МХЛ" 
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

end
