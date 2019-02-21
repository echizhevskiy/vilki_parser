require 'open-uri'
require 'nokogiri'
require 'date'
require 'watir'
require 'webdrivers'

class ParserController < ApplicationController

    #parser for parimatch
    def parse_parimatch
        html = open('https://www.parimatch.by/sport/khokkejj/kkhl')
        doc = Nokogiri::HTML(html.read)
        doc.encoding = 'utf-8'

        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |el|
            el.css('tbody.row1.props').each do |data|
                data['class']="row1 props processed"
            end
            el.css('tbody.row2.props').each do |data|
                data['class']="row2 props processed"
            end
        end

        #event = Struct.new(:date_variable, :match, :type)
        #event_data = []

        #bet = Struct.new(:kind, :office, :ratio, :attr_1, :attr_2)
        #bet_data = []
        
        detail_info = false
        doc.css('div#z_container div#z_contentw div#oddsList table.dt').each do |tbody|
            tbody.css('tbody.row1, tbody.row2').each do |data|
                if(detail_info == false)
                    events_from_parimatch = Event.new(date: data.css('tr td')[1].text.insert(5, ' '), 
                                                      match: data.css('tr td a.om').children.to_s.gsub('<br>', ' - '), 
                                                      match_kind: doc.css('div#z_container div#z_contentw div#oddsList div.container h3').text
                                                    )
                    events_from_parimatch.save
                    #event_data.push(events_from_parimatch)
                    detail_info = true
                else 
                    # обрабатываем детальную информацию о событии (ставки с коэффициентами)
                     #binding.pry
                     # ------------  парсим дополнительные (не парсит с заглавного события) тоталы с париматча                   
                    data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(2)').search('td:nth-child(1)').search('tr:nth-child(2)').text.split(';').each do |var|
                        array_attributes = [] 
                        var.split(' ').each do |get_attr|
                            array_attributes.push(get_attr)
                        end 
                        if (array_attributes.size%2 == 0)
                            total_for_event = Bet.new(event_id: Event.last.id,
                                                      kind: "total", #data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                      office: "parimatch",
                                                      ratio: array_attributes[1],
                                                      attr_1: Bet.last.attr_1,
                                                      attr_3: array_attributes[0]
                                                    )
                            total_for_event.save                        
                        else
                            total_for_event = Bet.new(event_id: Event.last.id,
                                                      kind: "total", #data.search('tr:nth-child(12)').search('td:nth-child(2)').search('tr:nth-child(1)').text,
                                                      office: "parimatch",
                                                      ratio: array_attributes[2],
                                                      attr_1: array_attributes[0].gsub!(/[^0-9,.]/,''),
                                                      attr_3: array_attributes[1]
                                                    )
                            total_for_event.save                         
                        end    
                    end
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
    end

    #parser for leon bet
    def parse_leon
        browser = Watir::Browser.new
        
        event_data = []
        bet_data = []
        browser.goto('https://www.leon.ru/events/IceHockey/562949953421985-Russia-KHL')

        browser.is(class: /material-icons keyboard_arrow_down/).each do |icon|
            icon.click
            sleep(0.3)

            doc = Nokogiri::HTML(browser.html)
            doc.encoding = 'utf-8'

            #достаю только раскрытые блоки в цикле, все остальные игнорируются
            doc.css('div.content div.fon div.body div.main span').each do |main|
                main.css('li.expanded').each do |data|
                        time = data.search('div:nth-child(1)').search('div:nth-child(1)').search('span:nth-child(1)').search('div:nth-child(1)').text
                        date = data.search('div:nth-child(1)').search('div:nth-child(1)').search('span:nth-child(1)').search('div:nth-child(2)').text
                        final_time = Time.parse time + " " + date
                        event_data.push({
                            date: final_time,    # формат Time   
                            match: data.search('div:nth-child(1)').search('div:nth-child(2)').search('div:nth-child(1)').search('a:nth-child(1)').search('span:nth-child(1)').text,
                            match_kind: main.css('div.head-title div.middle a').text.strip 
                        })
                    
                    data.search('div:nth-child(2)').search('ul:nth-child(1)').search('li:nth-child(2)').search('div:nth-child(4)').search('ul:nth-child(2)').css('li').each do |li| 
                        get_total_with_min_max = li.search('span:nth-child(1)').text.split(' ')
                        bet_data.push({
                            event_id: 1,
                            office: "leon",
                            kind: "total", 
                            ratio: li.search('span:nth-child(2)').text, 
                            attr_1: get_total_with_min_max[1].gsub!(/[^0-9,.]/,''),
                            attr_3: get_total_with_min_max[0].mb_chars.downcase.to_s 
                        })
                    end  
                end
            end            
        end
        puts event_data
        puts bet_data
     
        browser.close
    end

end
