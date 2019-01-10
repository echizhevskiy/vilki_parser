class ParserController < ApplicationController
    require 'open-uri'
    require 'nokogiri'
    require 'date'

    #parser for parimatch
    def parse_url
        html = open('https://www.parimatch.by/sport/khokkejj/kkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'

        #binding.pry
       # doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
           # el.xpath("//*[contains(@class, 'row1') and contains(@class, 'props')]").each do |date|
           #     puts date.text
           # end
           # el.css('tbody.row1').each do |date|
           #     puts date.text
           # end
       # end

        dates_from_webpage = [] # 08/01 15:30
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
            el.css('tbody.row2, tbody.row1').each do |date| 
                dates_from_webpage.push(date_variable: date.css('tr td')[1].text.insert(5, ' '), 
                                        match: date.css('tr td a.om').children.to_s.gsub('<br>', ' -- '), 
                                        type: doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text
                )
            end
            dates_from_webpage.each_with_index { |item, i| dates_from_webpage.delete_at(i+1)}

            el.css('tbody.row1.props tr table.ps tbody tr').each do |setting|
                puts setting
                #dates_from_webpage.push(total: setting.css('tr')[12].text
                                        #attr_1: setting.css('tr td ')
                #                         )
            end
        end
        puts dates_from_webpage
    end

end
