class ParserController < ApplicationController

    def call_all_parsers
        file = File.read('app/controllers/matches.json')
        data = JSON.parse(file)

        ParseJob.perform_later()
        FavbetJob.perform_later()
=begin
        Rails.application.executor.wrap do
            threads = []
            data.each_key do |office|
                data[office].each_key do |link|     
          
                    if office == 'parimatch'
                    threads << Thread.new do
                        Rails.application.executor.wrap do
                            Services::Scrapers::ParimatchScraperService.new.parse(link, data[office][link]) 
                        end
                    end

                    elsif office == 'leon'
                    #   p threads << Thread.new { Services::Scrapers::LeonScraperService.new.parse(link, data[office][link]) }
                        threads << Thread.new do
                            Rails.application.executor.wrap do
                                Services::Scrapers::LeonScraperService.new.parse(link, data[office][link]) 
                            end
                        end

                    elsif office == 'favbet'
                    #   p threads << Thread.new { Services::Scrapers::FavbetScraperService.new.parse(link, data[office][link]) } 
                        threads << Thread.new do
                            Rails.application.executor.wrap do
                                Services::Scrapers::FavbetScraperService.new.parse(link, data[office][link])
                            end
                        end
                    end
                end
            end
            ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
                threads.map(&:join) # внешний тред ждет здесь, но не имеет блокировки
            end
            #p threads.map(&:join)
            render 'calculate_arbitration/index'
        end
=end
    render 'calculate_arbitration/index' # redirect_to
    end
end
