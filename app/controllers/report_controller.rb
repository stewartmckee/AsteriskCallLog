class ReportController < ApplicationController
  before_filter :login_required
  
  SATURDAY = 6
  SUNDAY = 0

  CHARTS = [:this_week, :last_week, :this_month, :last_month, :month_to_date]
  CHART_TYPES = [:weekly, :monthly, :month_to_date]
  
  def index
    
    @chart = params[:chart_type].to_sym
    # find the monday just past
    (0..6).each do |d|
      date = Date.today-d.days
      if date.strftime("%A") == "Monday"
        @last_monday_date = date
        break
      end
    end
    
    # find the first monday of the month
    @start_date = Date.parse("01 #{Date.today.month} #{Date.today.year}")
    (0..6).each do |d|
      date = @start_date+d.days
      if date.strftime("%A") == "Monday"
        @first_monday = date
        break
      end
    end
    @first_friday = @first_monday+4.days
    
    if @chart == :this_week or @chart == :last_week 
      @chart_type = :weekly
      @last_monday_date = @last_monday_date - 1.week if @chart == :last_week  
    elsif @chart == :this_month or @chart == :last_month 
      @chart_type = :monthly
      if @chart == :last_month
        @start_date = Date.parse("01-#{(Date.today - 31.days).month}-#{Date.today.year}")
        (0..6).each do |d|
          date = @start_date+d.days
          if date.strftime("%A") == "Monday"
            @first_monday = date
            break
          end
        end
        @first_friday = @first_monday+4.days
      end  
    elsif @chart == :month_to_date
      @chart_type = :month_to_date
    end

    
    users = User.account_managers
    if @chart_type == :weekly
      weekly_calls = CdrEntries.for_users(users).after(@last_monday_date).reject{|c| c.user.nil?}.group_by{|call| call.user.fullname}
      users.each do |u|
        weekly_calls[u.fullname] = [] if weekly_calls[u.fullname].nil?
      end 
      week_dates = []
      (0..4).each do |d|
        week_dates << @last_monday_date + d.days
      end    
      @weekly_data = {:call_duration => generate_graph(weekly_calls, :duration, @chart_type, week_dates), :call_volume => generate_graph(weekly_calls, :volume, @chart_type, week_dates)}    
    elsif @chart_type == :monthly
      monthly_calls = CdrEntries.for_users(users).after(1.month.ago).reject{|c| c.user.nil?}.group_by{|call| call.user.fullname}
      month_dates = []
      (0..4).each do |w|
        month_dates << @first_friday + w.weeks unless ((@first_friday + w.weeks)-4.days).month != @first_friday.month 
      end
      @monthly_data = {:call_duration => generate_graph(monthly_calls, :duration, @chart_type, month_dates)  , :call_volume => generate_graph(monthly_calls, :volume, @chart_type, month_dates)}
    elsif @chart_type == :month_to_date
      month_to_date_calls = CdrEntries.for_users(users).after(@start_date - 1.day).reject{|c| c.user.nil?}.group_by{|call| call.user.fullname}
      month_dates = []
      (0..31).each do |w|
        month_dates << @start_date + w.days unless (@start_date + w.days) > Date.today or (@start_date + w.days).wday == SATURDAY or (@start_date + w.days).wday == SUNDAY 
      end
      @month_to_date_data = {:call_duration => generate_graph(month_to_date_calls, :duration, @chart_type, month_dates)  , :call_volume => generate_graph(month_to_date_calls, :volume, @chart_type, month_dates)}
      puts @month_to_date_data
    end
    
    @sub_nav = []
    CHARTS.each do |type|
      @sub_nav << [type.to_s.titleize, {:controller => "report", :action => "index", :chart_type => type}]
    end

  end
  
  private
  def generate_graph(calls, type, time_type, graph_dates=[])
    if time_type == :weekly
      graph_title = "Call #{type.to_s.titleize} - WE#{(@last_monday_date+4.days).strftime("%d%b%y").upcase}" if time_type == :weekly
      if type == :volume
        target_value = "50" 
      elsif type == :duration
        target_value = "125"
      end
    elsif time_type == :monthly
      graph_title = "Call #{type.to_s.titleize} - #{Date.today.strftime("%B").upcase}" if time_type == :monthly
      if type == :volume
        target_value = "250" 
      elsif type == :duration
        target_value = "625"
      end
    elsif time_type == :month_to_date
      graph_title = "Call #{type.to_s.titleize} - #{Date.today.strftime("%B").upcase}" if time_type == :monthly
      if type == :volume
        target_value = "50" 
      elsif type == :duration
        target_value = "125"
      end
    end
    
    y_label = "# of Dials" if type == :volume
    y_label = "# of Minutes" if type == :duration
      
    #settings = "<settings><font>Arial</font><text_size>11</text_size><text_color>626262</text_color><data_type>xml</data_type><preloader_on_reload>1</preloader_on_reload><thousands_separator>,</thousands_separator><digits_after_decimal>0</digits_after_decimal><precision>0</precision><background><alpha>100</alpha></background><plot_area><margins><left>230</left></margins></plot_area><grid><category><alpha>8</alpha><dashed>1</dashed><dash_length>8</dash_length></category><value><alpha>8</alpha><dashed>1</dashed></value></grid><axes><category><tick_length>0</tick_length><width>1</width><color>E7E7E7</color></category><value><tick_length>2</tick_length><width>1</width><color>E7E7E7</color></value></axes><values><category><color>000000</color><text_size>11</text_size></category><value><min>0</min></value></values><legend><x>0</x><y>0</y><width>200</width><max_columns>1</max_columns><spacing>2</spacing></legend><column><width>85</width><spacing>2</spacing><data_labels_text_color>FFFFFF</data_labels_text_color><data_labels_text_size>11</data_labels_text_size><data_labels_position>outside</data_labels_position><data_labels_always_on>1</data_labels_always_on><grow_time>0</grow_time><sequenced_grow>0</sequenced_grow><balloon_text>{value} {description}</balloon_text></column><depth>3</depth><angle>24</angle><line><bullet>round</bullet></line><labels><label lid=\"0\"><text><![CDATA[<b>#{graph_title.titleize}</b>]]></text><y>18</y><text_color>000000</text_color><text_size>24</text_size><rotate>0</rotate><align>center</align></label></labels>"
    settings = "<settings><font>Arial</font><text_size>11</text_size><text_color>626262</text_color><data_type>xml</data_type><preloader_on_reload>1</preloader_on_reload><thousands_separator>,</thousands_separator><digits_after_decimal>0</digits_after_decimal><precision>0</precision><background><alpha>100</alpha></background>"
    settings += "<plot_area><margins><right>170</right><top>70</top><bottom>50</bottom></margins></plot_area>"
    settings += "<grid><category><alpha>8</alpha><dashed>1</dashed><dash_length>8</dash_length></category><value><alpha>8</alpha><dashed>1</dashed></value></grid>"
    settings += "<axes><category><tick_length>0</tick_length><width>1</width><color>E7E7E7</color></category><value><tick_length>2</tick_length><width>1</width><color>E7E7E7</color></value></axes>"
    settings += "<values><category><color>000000</color><text_size>11</text_size></category><value><min>0</min></value></values>"
    settings += "<legend><x>620</x><y>60</y><max_columns>1</max_columns><spacing>2</spacing></legend>"
    settings += "<column><width>85</width><spacing>2</spacing><data_labels_text_color>FFFFFF</data_labels_text_color><data_labels_text_size>11</data_labels_text_size><data_labels_position>outside</data_labels_position><data_labels_always_on>1</data_labels_always_on><grow_time>0</grow_time><sequenced_grow>0</sequenced_grow><balloon_text>{value} {description}</balloon_text></column><depth>3</depth><angle>24</angle><line><bullet>round</bullet></line>"
    settings += "<labels>"
    settings += "<label lid=\"0\"><text><![CDATA[<b>#{graph_title}</b>]]></text><y>18</y><text_color>000000</text_color><text_size>24</text_size><rotate>0</rotate><align>center</align></label>"
    settings += "<label lid=\"1\"><text>#{y_label}</text><x>6</x><y>160</y><text_size>18</text_size><rotate>1</rotate><text_color>000000</text_color></label>"
    settings += "<label lid=\"2\"><text>Account Manager</text><x>-80</x><y>222</y><text_size>18</text_size><align>center</align><text_color>000000</text_color></label>"
    settings += "</labels>"
    settings += "<line><connect>1</connect></line>"
    settings += "<guides><guide gid=\"1\"><start_value>#{target_value}</start_value><color>FFFF33</color><width>2</width><dashed>1</dashed><centered>0</centered></guide></guides>"
    settings += "<data>"
    settings += generate_report_graph_data(calls, type, graph_dates)
    puts "---------------------------------"
    puts generate_report_graph_data(calls, type, graph_dates)
    settings += "</data>"
    settings += "<graphs>"
    graph_dates.each do |date|
      if time_type == :weekly
        settings += "<graph gid=\"#{date.to_s}\"><title>Sum for #{date.strftime("%A")}</title><color></color></graph>"
      elsif time_type == :monthly
        settings += "<graph gid=\"#{date.to_s}\"><title>Sum for WE #{(date).strftime("%d %b")}</title><color></color></graph>"
      elsif time_type == :month_to_date
        settings += "<graph gid=\"#{date.to_s}\"><title>Sum for #{(date).strftime("%d %b")}</title><color></color></graph>"
      end
    end
    settings += "</graphs></settings>"
    
    settings.gsub("'", "&#39;")
    
  end
  
  def generate_report_graph_data(calls, type, graph_dates)
        
     x = Builder::XmlMarkup.new(:indent => 0)
     x.chart {
      x.series {
        calls.each do |group, call_data|
          x.value(group.titleize, :xid => group) 
        end
      }
      x.graphs{
        graph_dates.each do |date|
          x.graph(:gid => date.to_s){
            calls.each do |group, call_data|
              call_data = CdrEntries.by_ids(call_data.map{|c|c.id})
              unless call_data.empty? or call_data.first.user.nil?
                if @chart_type == :monthly
                  call_for_user = call_data.for_extension(call_data.first.user.extension).after(date).before(date+7.days)
                else
                  call_for_user = call_data.for_extension(call_data.first.user.extension).on(date)
                end
                
                if type == :duration
                  x.value(call_for_user.sum(:billsec) / 60, :xid => group, :description => "minutes of calls on #{date}")
                else
                  x.value(call_for_user.count, :xid => group, :description => "calls on #{date} on #{group}")
                end
              end
            end
          }
        end
      }
     }.to_s
  end

  
end
