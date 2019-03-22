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

every 2.days do 
    runner "ParserController.new.parse_parimatch"
end