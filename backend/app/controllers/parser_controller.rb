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

        threads = []
        data.each_key do |office|
            data[office].each_key do |link|                
                if office == 'parimatch'
                   threads << Thread.new do
                     Services::Scrapers::ParimatchScraperService.new.parse(link, data[office][link]) 
                     ActiveRecord::Base.connection.close
                   end
                elsif office == 'leon'
                #   p threads << Thread.new { Services::Scrapers::LeonScraperService.new.parse(link, data[office][link]) }
                elsif office == 'favbet'
                #   p threads << Thread.new { Services::Scrapers::FavbetScraperService.new.parse(link, data[office][link]) } 
                end
            end
        end
        p threads.map(&:join)
        render 'calculate_arbitration/index'
    end

end
