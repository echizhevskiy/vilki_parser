class ParserController < ApplicationController
    require 'open-uri'
    require 'nokogiri'

    def parse_url
        
        html = open('https://www.parimatch.by/sport/khokkejj/kkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'
        
        dates = []
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
           el.css('tbody.row1, tbody.row2, tbody.processed').each do |date| 
                dates.push(test: date.css('tr.bk td')[1].text)
           end        
        #   dates.each_with_index { |item, i| dates.delete_at(i+1)}
        #   dates.each {|get_date| puts get_date.delete('/:')}
        end
        puts dates

        #tbody.row1 tr.bk td
        #doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el| 
        #    el.css('tbody.row1, tbody.processed').each do |date|
        #        puts date.css('tr.bk td')[1]
        #    end
           # events.push(
           #     date: dates,
           #     event: event
           # )
        #end
    end


end
