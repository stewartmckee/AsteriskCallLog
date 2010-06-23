# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def page_title
    "Calling Cards"
  end

  def application_title
    "Gannet"
  end

  def application_author
    "Active Information Design"
  end

  def time_in_words(total_seconds)
    raise "invalid number of seconds" if total_seconds.nil?
    format = "%H hours, %M minutes and %S seconds"
    format = "%M minutes and %S seconds" if total_seconds < 3600
    format = "%S seconds" if total_seconds < 60
    Time.at(total_seconds).strftime(format)
  end
  def seconds_in_time(total_seconds)
    raise "invalid number of seconds" if total_seconds.nil?
    format = "%H:%M:%S"
    format = "%M:%S" if total_seconds < 3600
    format = "%S" if total_seconds < 60
    Time.at(total_seconds).strftime(format)
  end
end
