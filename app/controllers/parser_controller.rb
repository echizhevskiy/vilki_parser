class ParserController < ApplicationController
    require 'open-uri'
    require 'nokogiri'

    def parse_url
        html = open('https://www.parimatch.by/sport/khokkejj/kkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'
        
        dates_from_webpage = [] # 08/0115:30
        dates_with_format = [] # 08011530 = 8 января 15.30
        doc.css('div#z_container div#z_contentw div#oddsList div.container div.wrapper table#g11234133').each do |el|
            el.css('tbody.row2, tbody.row1, tbody.processed').each {|date| dates_from_webpage.push(date.css('tr td')[1].text)} 
        end
        dates_from_webpage.each_with_index { |item, i| dates_from_webpage.delete_at(i+1)}
        dates_from_webpage.each {|get_date| dates_with_format.push(get_date.delete('/:'))}
    end

end
