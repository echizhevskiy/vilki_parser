require 'open-uri'
require 'nokogiri'
require 'date'
require 'watir'
require 'webdrivers'
require 'headless'

class ParserController < ApplicationController

    def call_all_parsers
        Services::Scrapers::ParimatchScraperService.new.parse
        Services::Scrapers::LeonScraperService.new.parse
    end

end
