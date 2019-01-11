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
        # <tbody class="row1"></tbody>
        # <tbody class="row1 props"></tbody>

        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
            el.css('tbody.row1.props').each do |data|
                data['class']="row1 props processed"
            end
            el.css('tbody.row2.props').each do |data|
                data['class']="row2 props processed"
            end
        end

        dates_from_webpage = []
        total_data = []
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |tbody|
            tbody.css('tbody.row1', 'tbody.row2').each do |data|
                dates_from_webpage.push(date_variable: data.css('tr td')[1].text.insert(5, ' '), 
                                        match: data.css('tr td a.om').children.to_s.gsub('<br>', ' -- '), 
                                        type: doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text
                                       )
            end
            dates_from_webpage.each_with_index { |item, i| dates_from_webpage.delete_at(i+1)}

            #binding.pry
            tbody.css('tbody.row1.props.processed tr td table.ps').each do |td|
                total_data.push(total: td.css('tr td')[0].text) 
            end
        end
        puts total_data
        #puts dates_from_webpage


        #dates_from_webpage = [] # 08/01 15:30
        #doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
        #    el.css('tbody.row2, tbody.row1').each do |date| 
        #        dates_from_webpage.push(date_variable: date.css('tr td')[1].text.insert(5, ' '), 
        #                                match: date.css('tr td a.om').children.to_s.gsub('<br>', ' -- '), 
        #                                type: doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text
        #        )
        #    end
        #    dates_from_webpage.each_with_index { |item, i| dates_from_webpage.delete_at(i+1)}

           # el.css('tbody.row1.props tr table.ps tbody tr').each do |setting|
           #     setting.css('')
                #dates_from_webpage.push(total: setting.css('tr')[12].text
                                        #attr_1: setting.css('tr td ')
                #                         )
           # end
        #end
        #puts dates_from_webpage
    end

end
