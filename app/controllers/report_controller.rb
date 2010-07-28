class ReportController < ApplicationController
  before_filter :login_required
  
  SATURDAY = 6
  SUNDAY = 0  
  
  def index
  
    (0..6).each do |d|
      date = Date.today-d.days
      if date.strftime("%A") == "Monday"
        @last_monday_date = date
        break
      end
    end  
    
    users = [current_user]
    users = User.all if current_user.admin?
    
    dates = [4.days.ago, 3.days.ago, 2.days.ago, 1.days.ago, DateTime.now]     
    
    weekly_calls = CdrEntries.after(@last_monday_date).reject{|c| c.user.nil?}.group_by{|call| call.user.fullname}
    
    
    users.each do |u|
      weekly_calls[u.fullname] = [] if weekly_calls[u.fullname].nil?
    end 

    monthly_calls = CdrEntries.after(1.month.ago).reject{|c| c.user.nil?}.group_by{|call| call.user.fullname}
    
    week_dates = []
    (0..4).each do |d|
      week_dates << @last_monday_date + d.days
    end
    month_dates = []
    start_date = Date.parse("01 #{Date.today.month} #{Date.today.year}") 
    (0..4).each do |w|
      month_dates << start_date + w.weeks unless (start_date + w.weeks).month != start_date.month 
    end
    
    @weekly_data = {:call_duration => generate_graph(weekly_calls, :duration, :weekly, week_dates), :call_volume => generate_graph(weekly_calls, :volume, :weekly, week_dates)}    
    @monthly_data = {:call_duration => generate_graph(monthly_calls, :duration, :monthly, month_dates)  , :call_volume => generate_graph(monthly_calls, :volume, :monthly, month_dates)}
    
    puts @weekly_data[:call_duration]
  end
  
  private
  def generate_graph(calls, type, time_type, graph_dates=[])
    graph_title = "Call #{type.to_s.titleize} - WE#{(@last_monday_date+4.days).strftime("%d%b%y").upcase}" if time_type == :weekly
    graph_title = "Call #{type.to_s.titleize} - #{Date.today.strftime("%B").upcase}" if time_type == :monthly
    target_value = "50" if type == :volume 
    target_value = "125" if type == :duration

    #settings = "<settings><font>Arial</font><text_size>11</text_size><text_color>626262</text_color><data_type>xml</data_type><preloader_on_reload>1</preloader_on_reload><thousands_separator>,</thousands_separator><digits_after_decimal>0</digits_after_decimal><precision>0</precision><background><alpha>100</alpha></background><plot_area><margins><left>230</left></margins></plot_area><grid><category><alpha>8</alpha><dashed>1</dashed><dash_length>8</dash_length></category><value><alpha>8</alpha><dashed>1</dashed></value></grid><axes><category><tick_length>0</tick_length><width>1</width><color>E7E7E7</color></category><value><tick_length>2</tick_length><width>1</width><color>E7E7E7</color></value></axes><values><category><color>000000</color><text_size>11</text_size></category><value><min>0</min></value></values><legend><x>0</x><y>0</y><width>200</width><max_columns>1</max_columns><spacing>2</spacing></legend><column><width>85</width><spacing>2</spacing><data_labels_text_color>FFFFFF</data_labels_text_color><data_labels_text_size>11</data_labels_text_size><data_labels_position>outside</data_labels_position><data_labels_always_on>1</data_labels_always_on><grow_time>0</grow_time><sequenced_grow>0</sequenced_grow><balloon_text>{value} {description}</balloon_text></column><depth>3</depth><angle>24</angle><line><bullet>round</bullet></line><labels><label lid=\"0\"><text><![CDATA[<b>#{graph_title.titleize}</b>]]></text><y>18</y><text_color>000000</text_color><text_size>24</text_size><rotate>0</rotate><align>center</align></label></labels>"
    settings = "<settings><font>Arial</font><text_size>11</text_size><text_color>626262</text_color><data_type>xml</data_type><preloader_on_reload>1</preloader_on_reload><thousands_separator>,</thousands_separator><digits_after_decimal>0</digits_after_decimal><precision>0</precision><background><alpha>100</alpha></background>"
    settings += "<plot_area><margins><right>170</right><top>70</top><bottom>50</bottom></margins></plot_area>"
    settings += "<grid><category><alpha>8</alpha><dashed>1</dashed><dash_length>8</dash_length></category><value><alpha>8</alpha><dashed>1</dashed></value></grid>"
    settings += "<axes><category><tick_length>0</tick_length><width>1</width><color>E7E7E7</color></category><value><tick_length>2</tick_length><width>1</width><color>E7E7E7</color></value></axes>"
    settings += "<values><category><color>000000</color><text_size>11</text_size></category><value><min>0</min></value></values>"
    settings += "<legend><x>460</x><y>60</y><max_columns>1</max_columns><spacing>2</spacing></legend>"
    settings += "<column><width>85</width><spacing>2</spacing><data_labels_text_color>FFFFFF</data_labels_text_color><data_labels_text_size>11</data_labels_text_size><data_labels_position>outside</data_labels_position><data_labels_always_on>1</data_labels_always_on><grow_time>0</grow_time><sequenced_grow>0</sequenced_grow><balloon_text>{value} {description}</balloon_text></column><depth>3</depth><angle>24</angle><line><bullet>round</bullet></line>"
    settings += "<labels><label lid=\"0\"><text><![CDATA[<b>#{graph_title}</b>]]></text><y>18</y><text_color>000000</text_color><text_size>24</text_size><rotate>0</rotate><align>center</align><label lid=\"1\"><text># of Dials</text><x>6</x><y>160</y><text_size>18</text_size><rotate>1</rotate></label><label lid=\"2\"><text>Account Manager</text><x>-80</x><y>222</y><text_size>18</text_size><align>center</align></label></label></labels>"
    settings += "<line><connect>1</connect></line>"
    settings += "<guides><guide gid=\"1\"><start_value>#{target_value}</start_value><color>FFFF33</color><width>2</width><dashed>1</dashed><centered>0</centered></guide></guides>"
    settings += "<data>"
    settings += generate_report_graph_data(calls, type, graph_dates)
    settings += "</data>"
    settings += "<graphs>"
    graph_dates.each do |date|
      if time_type == :weekly
        settings += "<graph gid=\"#{date.to_s}\"><title>Sum for #{date.strftime("%A")}</title><color></color></graph>"
      else
        settings += "<graph gid=\"#{date.to_s}\"><title>Sum for #{(date).strftime("%d %b")}</title><color></color></graph>"
      end
    end
    settings += "</graphs></settings>"
    
    settings.gsub("'", "&#39;")
    
  end
  
  def generate_report_graph_data(calls, type, graph_dates)
        
     x = Builder::XmlMarkup.new(:indent => 0)
     puts calls.class
     x.chart {
      x.series {
        calls.each do |group, call_data|
          x.value(group, :xid => group) 
        end
      }
      x.graphs{
        graph_dates.each do |date|
          x.graph(:gid => date.to_s){
            calls.each do |group, call_data|
              call_data = CdrEntries.by_ids(call_data.map{|c|c.id})
              unless call_data.first.user.nil?
                if type == :duration
                  x.value(call_data.for_extension(call_data.first.user.extension).on(date).sum(:billsec) / 60, :xid => group, :description => "minutes of calls on #{date}")
                else
                  x.value(call_data.for_extension(call_data.first.user.extension).on(date).count, :xid => group, :description => "calls on #{date} on #{group}")
                end
              end
            end
          }
        end
      }
     }.to_s
  end

  
end
