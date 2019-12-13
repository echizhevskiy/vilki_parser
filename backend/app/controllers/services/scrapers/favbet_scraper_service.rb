module Services
    module Scrapers
        class FavbetScraperService < BaseScraperService
            def parse(link, match_kind)
                Headless.ly do
                  #  binding.pry
                    browser = Watir::Browser.new
                        start_parsing_time = Time.now
                        event_data = []
                        bet_data = []

                        browser.goto(link)
                        sleep(1.5)

                        browser.uls(class: /events--list/).each do |event|
                            event.lis(class: /event--head-block/).each do |press_button_with_info|
                                event_info = Nokogiri::HTML(press_button_with_info.html)
                                event_info.encoding = 'utf-8'
                                home_team = event_info.css('div.event--name--info div.event--name').text.split('-')[0]
                                guest_team = event_info.css('div.event--name--info div.event--name').text.split('-')[1].lstrip
                                
                                date = event_info.css('div.event--date').text
                                time = event_info.css('div.event--time').text

                                final_time = Time.parse time + " " + date
                                final_time = final_time + 10800

                                event_data = Event.new(
                                    date: final_time,
                                    home_team: home_team,
                                    guest_team: guest_team,
                                    match_kind: match_kind 
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

                                press_button_with_info.divs(class: /event--more/).each do |k|
                                  #  binding.pry
                                    k.button.click
                                    sleep(0.4)

                                    page_with_more_info = Nokogiri::HTML(browser.html)
                                    page_with_more_info.encoding = 'utf-8'

                                   # binding.pry
                                    page_with_more_info.css('ul.market--column--0').each do |list|
                                        if list.search('li:nth-child(7)').search('div:nth-child(1)')[0].text == 'Тотал'
                                            list.search('li:nth-child(7)').search('ul:nth-child(3)').search('li:nth-child(1)').search('ul:nth-child(2)').each do |li|
                                                li.search('label:nth-child(1)').each do |line_with_bets|
                                                    total_number = line_with_bets.search('span:nth-child(1)').text.mb_chars.downcase.to_s.split(' ')[1].delete('()')
                                                    total_min_max = line_with_bets.search('span:nth-child(1)').text.mb_chars.downcase.to_s.split(' ')[0]
                                                    ratio = line_with_bets.search('button:nth-child(2)').text
                                                   # binding.pry
                                                    bet_data = Bet.new(
                                                        event_id: @event_id,
                                                        kind: "total",
                                                        office: "favbet",
                                                        ratio: ratio,
                                                        attr_1: total_number,
                                                        attr_3: total_min_max,
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
                        end
                    browser.close
                    cleanup_previous_bets(@temp_match_kind, 'favbet')
                end
            end
        end
    end
end