require 'open-uri'
require 'nokogiri'
require 'date'
require 'watir'
require 'webdrivers'

class ParserController < ApplicationController

    #parser for parimatch
    def parse_parimatch
        html = open('https://pm.by/sport/khokkejj/mkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'

        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
            el.css('tbody.row1.props').each do |data|
                data['class']="row1 props processed"
            end
            el.css('tbody.row2.props').each do |data|
                data['class']="row2 props processed"
            end
        end

        #event = Struct.new(:date_variable, :match, :type)
        #event_data = []

        #bet = Struct.new(:kind, :office, :ratio, :attr_1, :attr_2)
        #bet_data = []
        
        detail_info = false
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |tbody|
            tbody.css('tbody.row1, tbody.row2').each do |data|
                if(detail_info == false)

                    # Получаем дату в формате 23/02 13:30 UTC +2 (при скачивании html страницы), отображается для пользователя в формате UTC +3
                    # Преобразовываем дату в формат Time 2019-02-23 14:30:00 +0300
                    date_from_parimatch = data.css('tr td')[1].text.insert(5, ' ').split(' ') # ["23/02", "13:30" ]
                    date_from_parimatch[1] = date_from_parimatch[1].to_time + 3600  # ["23/02", "2019-02-22 14:30:00 +0300" ]
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
                    
                    if is_event_in_database?(events_from_parimatch.date, events_from_parimatch.match_kind, events_from_parimatch.home_team, events_from_parimatch.guest_team)
                        puts "True value"
                    else
                        events_from_parimatch.save
                    end
                    #event_data.push(events_from_parimatch)
                    detail_info = true
                else 
                    # обрабатываем детальную информацию о событии (ставки с коэффициентами)
                     #binding.pry
                     # ------------  парсим дополнительные (не парсит с заглавного события) тоталы с париматча                   
                    data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('td:nth-child(1)').search('tr:nth-child(2)').text.split(';').each do |var|
                        array_attributes = [] 
                        var.split(' ').each do |get_attr|
                            array_attributes.push(get_attr)
                        end 
                        if (array_attributes.size%2 == 0)
                            total_for_event = Bet.new(event_id: Event.last.id,
                                                      kind: "total", #data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                      office: "parimatch",
                                                      ratio: array_attributes[1],
                                                      attr_1: Bet.last.attr_1,
                                                      attr_3: array_attributes[0]
                                                    )
                            total_for_event.save                        
                        else
                            total_for_event = Bet.new(event_id: Event.last.id,
                                                      kind: "total", #data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                      office: "parimatch",
                                                      ratio: array_attributes[2],
                                                      attr_1: array_attributes[0].gsub!(/[^0-9,.]/,''),
                                                      attr_3: array_attributes[1]
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
    end

    #parser for leon bet
    def parse_leon
        browser = Watir::Browser.new
        
        event_data = []
        bet_data = []
        browser.goto('https://www.leon.ru/events/IceHockey/562949953432733-Russia-MHL')

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
                        teams = data.search('div:nth-child(1)').search('div:nth-child(2)').search('div:nth-child(1)').search('a:nth-child(1)').search('span:nth-child(1)').text.split(' - ')

                        event_data = Event.new(
                                            date: final_time,
                                            home_team: teams[0],
                                            guest_team: teams[1],
                                            match_kind: main.css('div.head-title div.middle a').text.strip.delete(' ').gsub(/-.*-/, '.')                              
                                            )
                        event_data.save
                       # event_data.push({
                       #     date: final_time,    # формат Time   
                       #     match: data.search('div:nth-child(1)').search('div:nth-child(2)').search('div:nth-child(1)').search('a:nth-child(1)').search('span:nth-child(1)').text,
                       #     match_kind: main.css('div.head-title div.middle a').text.strip.delete(' ').gsub(/-.*-/, '.')
                       # })
                    
                    data.search('div:nth-child(2)').search('ul:nth-child(1)').search('li:nth-child(2)').search('div:nth-child(4)').search('ul:nth-child(2)').css('li').each do |li| 
                        get_total_with_min_max = li.search('span:nth-child(1)').text.split(' ')
                        bet_data = Bet.new(
                                        event_id: Event.last.id,
                                        kind: "total",
                                        office: "leon",
                                        ratio: li.search('span:nth-child(2)').text, 
                                        attr_1: get_total_with_min_max[1].gsub!(/[^0-9,.]/,''),
                                        attr_3: get_total_with_min_max[0].mb_chars.downcase.to_s                                  
                                        )
                        bet_data.save
                       # bet_data.push({
                       #     event_id: 1,
                       #     office: "leon",
                       #     kind: "total", 
                       #     ratio: li.search('span:nth-child(2)').text, 
                       #     attr_1: get_total_with_min_max[1].gsub!(/[^0-9,.]/,''),
                       #     attr_3: get_total_with_min_max[0].mb_chars.downcase.to_s 
                       # })
                    end  
                end
            end            
        end
        #puts event_data
        #puts bet_data    
        browser.close
    end


    private

    def is_event_in_database?(final_date, match_kind, home_team, guest_team)
        get_events = Event.where(match_kind: match_kind, date: final_date)
        if get_events.empty?
            return false
        else
            get_home_team = get_events.collect {|event| event.home_team}
            get_guest_team = get_events.collect {|event| event.guest_team}

            get_home_team.collect do |team|
                if(team == home_team)
                puts "#{team} is exist on db"
                return true
                elsif (team.include? home_team)
                    puts "#{team} contains #{home_team}"
                    return true
                elsif (home_team.include? team)
                    puts "#{home_team} includes #{team}"
                    return true
                else
                    return false
                end
            end
        end
    end

end
