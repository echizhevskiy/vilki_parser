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

        
        event = Struct.new(:date_variable, :match, :type)
        event_data = []

        bet = Struct.new(:kind, :office, :ratio, :attr_1, :attr_2)
        bet_data = []
        
        detail_info = false
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |tbody|
            tbody.css('tbody.row1', 'tbody.row2').each do |data|
                if(detail_info == false)
                    events_from_parimatch = event.new(data.css('tr td')[1].text.insert(5, ' '), 
                                                    data.css('tr td a.om').children.to_s.gsub('<br>', ' -- '), 
                                                    doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text)
                    event_data.push(events_from_parimatch)
                    detail_info = true
                else 
                    # обрабатываем детальную информацию о событии (ставки с коэффициентами)

                    detail_info = false
                end
            end
            # event_data.each_with_index { |item, i| event_data.delete_at(i+1)}

            #bets_from_parimatch = bet.new()
           # tbody.css('tbody.row1.props.processed tr td table.ps').each do |td|
           #        puts td.text
           #         bet_data.push(ratio: td.css('tr td')[0].text) 
           # end
        end
        puts event_data


        # -------------------------- отображение события (дата, играющие команды, тип поединка)-------------------------
        # ----------   #<struct date_variable="13/01 12:30", match="Сибирь -- Салават Юлаев", type="Хоккей. КХЛ"> ------
        #event_data.each do |data|
        #    puts data
        #end
        # --------------------------------------------------------------------------------------------------------------



    end

end
