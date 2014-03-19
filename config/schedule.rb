# -*- encoding : utf-8 -*-
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "log/cron.log"

every :monday, :at => '2am' do
  rake "relic:export"
end

every :day, :at => '1am' do
  rake "uploads:remove_not_saved"
end
