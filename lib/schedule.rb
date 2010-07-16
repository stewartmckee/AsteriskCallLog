require File.expand_path(File.dirname(__FILE__) + '/../config/environment.rb')
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '2m' do
  puts 'Updating CDR Entries...'
  
  CdrEntries.update_from_log
  
end
scheduler.join
