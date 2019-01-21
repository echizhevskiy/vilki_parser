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
                     #binding.pry
                     # ------------  парсим дополнительные тоталы с париматча                   
                    data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('td:nth-child(1)').search('td:nth-child(2)').text.split(';').each do |var|
                        array_attributes = [] 
                        var.split(' ').each do |get_attr|
                            array_attributes.push(get_attr)
                        end 
                       # puts array_attributes.size
                       # puts "-----------------------------------"
                       #binding.pry
                        if (array_attributes.size%2 == 0)
                            array_attributes.push(copy_array_attributes[0])
                            total_for_event = bet.new(data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                    'parimatch',
                                                    array_attributes[1],
                                                    array_attributes[2],
                                                    array_attributes[0]
                                                    )
                            bet_data.push(total_for_event)
                            
                        else
                            copy_array_attributes = []
                            copy_array_attributes.push(array_attributes.compact) # копирует массив, удаляя все nill из него 
                            total_for_event = bet.new(data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                    'parimatch',
                                                    array_attributes[2],
                                                    array_attributes[0],
                                                    array_attributes[1]
                                                    )
                            bet_data.push(total_for_event)
                        end    
                    end
                    puts bet_data
                     #-------------------------------------------------------- 

                     #------------- парсим индивидуальный тотал домашней команды с париматча
                     #get_total_team_home = data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('tr:nth-child(3)').text.split(";")
                     #puts get_total_team_home

                     # ---------------------------------------------------------------------

                    
                    #-------------- парсим индивидуальный тотал гостевой команды с париматча


                    # ---------------------------------------------------------------------
                                     
                    #total_for_event = bet.new(data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                    #                          'parimatch'
                    #                        )
                    #puts data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('tr:nth-child(2)').text
                    # ----- result_ratio.each {|var| var.gsub!(/[^0-9]\./,' ')}
                    # ----- result_ratio

                    detail_info = false
                end
            end
        end
        #puts bet_data
        #puts event_data


        # -------------------------- отображение события (дата, играющие команды, тип поединка)-------------------------
        # ----------   #<struct date_variable="13/01 12:30", match="Сибирь -- Салават Юлаев", type="Хоккей. КХЛ"> ------
        #event_data.each do |data|
        #    puts data
        #end
        # --------------------------------------------------------------------------------------------------------------



    end

end
