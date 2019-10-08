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

        data.each_key do |office|
            data[office].each_key do |link|
                if office == 'parimatch'
                    Services::Scrapers::ParimatchScraperService.new.parse(link, data[office][link])
                elsif office == 'leon'
                    Services::Scrapers::LeonScraperService.new.parse(link, data[office][link])
                end           
            end
        end

        render 'calculate_arbitration/index'
    end

end
