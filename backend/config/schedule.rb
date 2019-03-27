# install "whenever" gem
# run "wheneverize ." in root folder of backend
# edit config/schedule.rb
# "whenever --update-crontab" after every refresh

set :environment, :development
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
set :output, { :error => "log/error.log", :standard => 'log/cron.log' }
set :path, '/home/echizhevsly/scripts/vilki_parser/backend'

job_type :runner, "cd :path && bundle exec rails runner -e :environment ':task' :output"

every 2.hours do 
    runner "ParserController.new.call_all_parsers"
end

every 3.hours do
    runner "Services::Dbhelper::DbHelperService.cleanup_out_of_date_events"
end