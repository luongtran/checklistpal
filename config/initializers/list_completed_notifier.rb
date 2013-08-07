require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

#scheduler.cron("0 59 23 * * 1-5") do
#   List.completed_notifier
#end

# cron test
scheduler.every("24h") do
  List.completed_notifier
end