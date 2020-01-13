class ParseJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Services::Scrapers::LeonScraperService.new.parse('https://www.leon.ru/events/IceHockey/1970324836981174-Russia-VHL', 'VHL.Hockey')
  end
end
