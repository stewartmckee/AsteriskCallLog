ENV['RAILS_ENV'] = "production"

require "rubygems"
require "daemons"

Daemons.run("lib/schedule.rb")
