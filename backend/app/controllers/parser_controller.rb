require 'open-uri'
require 'nokogiri'
require 'date'
require 'watir'
require 'webdrivers'
require 'headless'
require 'json'

class ParserController < ApplicationController

    def call_all_parsers
        file = File.read('app/controllers/matches.json')
        data = JSON.parse(file)

        Rails.application.executor.wrap do
            threads = []
            data.each_key do |office|
                data[office].each_key do |link|     
=begin           
                    if office == 'parimatch'
                    threads << Thread.new do
                        Rails.application.executor.wrap do
                            Services::Scrapers::ParimatchScraperService.new.parse(link, data[office][link]) 
                        end
                    end
=end
                    if office == 'leon'
                    #   p threads << Thread.new { Services::Scrapers::LeonScraperService.new.parse(link, data[office][link]) }
                        threads << Thread.new do
                            Rails.application.executor.wrap do
                                Services::Scrapers::LeonScraperService.new.parse(link, data[office][link]) 
                            end
                        end
=begin
                    elsif office == 'favbet'
                    #   p threads << Thread.new { Services::Scrapers::FavbetScraperService.new.parse(link, data[office][link]) } 
                        threads << Thread.new do
                            Rails.application.executor.wrap do
                                Services::Scrapers::FavbetScraperService.new.parse(link, data[office][link])
                            end
                        end
=end
                    end
                end
            end
            ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
                threads.map(&:join) # внешний тред ждет здесь, но не имеет блокировки
            end
            #p threads.map(&:join)
            render 'calculate_arbitration/index'
        end
    end

end
