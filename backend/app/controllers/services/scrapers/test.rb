load 'parimatch_scraper_service.rb'
load 'base_scraper_service.rb'
require 'watir'
require 'open-uri'
require 'webdrivers'
require 'selenium-webdriver'
require 'headless'

threads = []

threads << Thread.new { Services::Scrapers::ParimatchScraperService.new.parse('https://pm.by/sport/khokkejj/vkhl', "VHL.Hockey") }

p threads.map(&:join)