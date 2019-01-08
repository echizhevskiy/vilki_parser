class ParserController < ApplicationController
    require 'open-uri'
    require 'nokogiri'

    def parse_url
        html = open('https://www.parimatch.by/sport/khokkejj/kkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'
        
        dates_from_webpage = [] # 08/0115:30
        dates_with_format = [] # 08011530 = 8 января 15.30 UTC +2
        doc.css('div#z_container div#z_contentw div#oddsList div.container div.wrapper table#g11234133').each do |el|
            el.css('tbody.row2, tbody.row1, tbody.processed').each do |date| 
                dates_from_webpage.push(date_variable: date.css('tr td')[1].text.delete('/:'), 
                                        event: date.css('tr td a.om').children.to_s.gsub('<br>', ' -- '),
                                        total: date.css('tr td')[5].children.to_s
                )
            end
        end
       # dates_from_webpage.each_with_index { |item, i| dates_from_webpage.delete_at(i+1)}
        puts dates_from_webpage
    end

end
