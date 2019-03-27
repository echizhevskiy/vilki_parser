module Services
    module Scrapers
        class LeonScraperService < BaseScraperService
            def parse
                Headless.ly do
                    browser = Watir::Browser.new
                    
                        start_parsing_time = Time.now
                        event_data = []
                        bet_data = []
                        browser.goto('https://www.leon.ru/events/IceHockey/562949953441000-Russia-VHL-Playoffs')
        
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
                                            if event_data.save
                                            else
                                                puts "Event " + event_data + "hasn't been saved to the DataBase"
                                            end
                                            @event_id = Event.last.id
                                        else
                                            @event_id = find_event_in_database(event_data.date, event_data.match_kind, event_data.home_team, event_data.guest_team)
                                        end
                                    #ищем нужную секцию с тоталом
                                    data.search('div:nth-child(2)').search('ul:nth-child(1)').search('li:nth-child(2)').css('div').each do |div|
                                        if (div.search('div:nth-child(1)').text.strip == "Тотал")
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
                                                if bet_data.save
                                                else
                                                    puts "Bet " + bet_data + "hasn't been saved to the DataBase"
                                                end
                                            end
                                        end  
                                    end  
        
                                end
                            end            
                        end
                    browser.close
                end
                cleanup_previous_bets(@temp_match_kind, 'leon')
            end
        end
    end
end