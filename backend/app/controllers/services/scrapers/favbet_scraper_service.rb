module Services
    module Scrapers
        class FavbetScraperService < BaseScraperService
            def parse(link, match_kind)
              #  Headless.ly do
                    binding.pry
                    browser = Watir::Browser.new
                        start_parsing_time = Time.now

                        browser.goto(link)
=begin
                        doc = Nokogiri::HTML(browser.html)
                        doc.encoding = 'utf-8'

                        doc.css('ul.events--list').each do |event|
                            binding.pry
                            puts "hello, man"
                        end
=end
                        browser.lis(class: /event--head-block/).each do |event|
                            binding.pry

                            doc = Nokogiri::HTML(browser.html)
                            doc.encoding = 'utf-8'
                            event.divs(class: /event--more/).each do |k|
                                k.button.click

                                doc.css('div.wrapper full--version--site div.contentdiv div#middle div#container div.prebet div.column2').each do |data|
                                    #date = data.search('div:nth-child(1)').search('div:nth-child(2)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(1)').search('div:nth-child(4)').search('div:nth-child(1)').text #.search('div:nth-child(4)').search('div:nth-child(1)').search('ul:nth-child(1)')
                                    

                                    puts "hi vasya"
                                end
                            end
                            sleep(0.4)
                        end

                    browser.close
                end
           # end
        end
    end
end