module Services
    module Scrapers
        class FavbetScraperService < BaseScraperService
            def parse(link, match_kind)
                Headless.ly do
                    binding.pry
                    browser = Watir::Browser.new
                        start_parsing_time = Time.now

                        browser.goto(link)

                        browser.is(class: /event--head-block/).each do |event|
                            binding.pry
                            event.is(class: /event--more/).button.click
                        end
                        
                        browser.is(class: /event--more/).each do |button|
                            binding.pry
                            button.is(button).click
                            sleep(0.4)
        
                            doc = Nokogiri::HTML(browser.html)
                            doc.encoding = 'utf-8'
                                            
                            binding.pry
            
                            doc.css('div.wrapper full--version--site div.contentdiv div#middle div#container div.prebet div.column2').each do |data|
                                date = data.search('div:nth-child(1)').search('div:nth-child(2)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(4)').search('div:nth-child(1)').text #.search('div:nth-child(4)').search('div:nth-child(1)').search('ul:nth-child(1)')

                            end
                        end
                    browser.close
                end
            end
        end
    end
end