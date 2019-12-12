module Services
    module Scrapers
        class FavbetScraperService < BaseScraperService
            def parse(link, match_kind)
              #  Headless.ly do
                    binding.pry
                    browser = Watir::Browser.new
                        start_parsing_time = Time.now
                        event_data = []
                        bet_data = []

                        browser.goto(link)

                        browser.lis(class: /event--head-block/).each do |event|

                            doc = Nokogiri::HTML(browser.html)
                            doc.encoding = 'utf-8'

                            test = Nokogiri::HTML(event.html)
                            time = browser.

                            event.divs(class: /event--more/).each do |k|
                                k.button.click
                                page_with_more_info = Nokogiri::HTML(browser.html)
                                page_with_more_info.encoding = 'utf-8'
                                
                                page_with_more_info.css('ul.market--column--0').each do |list|
                                    if list.search('li:nth-child(7)').search('div:nth-child(1)')[0].text == 'Тотал'
                                        list.search('li:nth-child(7)').search('ul:nth-child(3)').search('li:nth-child(1)').search('ul:nth-child(2)').each do |li|
                                            li.search('label:nth-child(1)').each do |line_with_bets|
                                                total_number = line_with_bets.search('span:nth-child(1)').text.mb_chars.downcase.to_s.split(' ')[1].delete('()')
                                                total_min_max = line_with_bets.search('span:nth-child(1)').text.mb_chars.downcase.to_s.split(' ')[0]
                                                ratio = line_with_bets.search('button:nth-child(2)').text
                                                binding.pry
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
                            binding.pry
                            sleep(0.4)
                        end

                    browser.close
                end
           # end
        end
    end
end