class FavbetJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Services::Scrapers::FavbetScraperService.new.parse('https://favbet.by/ru/bets/#tours=17451', 'VHL.Hockey')
  end
end
