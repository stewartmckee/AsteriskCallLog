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
    
    weekly_calls = CdrEntries.after(@last_monday_date).group_by{|call| call.calldate.strftime("%d/%m/%Y")}
    monthly_calls = CdrEntries.after(1.month.ago).group_by{|call| call.calldate.strftime("Week %W")}
    
    @weekly_data = {:call_duration => generate_graph(users, weekly_calls, :duration, (Date.today - @last_monday_date)), :call_volume => generate_graph(users, weekly_calls, :volume, (Date.today - @last_monday_date))}    
    @monthly_data = {:call_duration => generate_graph(users, monthly_calls, :duration, (Date.today - (@last_monday_date - 4.weeks))), :call_volume => generate_graph(users, monthly_calls, :volume, (Date.today - (@last_monday_date - 4.weeks)))}
  end
  
  private
  def generate_graph(users, calls, type, graph_days=7)
    settings = "<settings><font>Arial</font><text_size>11</text_size><text_color>626262</text_color><data_type>xml</data_type><preloader_on_reload>1</preloader_on_reload><thousands_separator>,</thousands_separator><digits_after_decimal>0</digits_after_decimal><precision>0</precision><background><alpha>100</alpha></background><plot_area><margins><left>230</left><right>18</right><top>10</top><bottom>10</bottom></margins></plot_area><grid><category><alpha>8</alpha><dashed>1</dashed><dash_length>8</dash_length></category><value><alpha>8</alpha><dashed>1</dashed></value></grid><axes><category><tick_length>0</tick_length><width>1</width><color>E7E7E7</color></category><value><tick_length>2</tick_length><width>1</width><color>E7E7E7</color></value></axes><values><category><color>000000</color><text_size>11</text_size><inside>1</inside><rotate>90</rotate></category><value><min>0</min></value></values><legend><x>0</x><y>0</y><width>200</width><max_columns>1</max_columns><spacing>2</spacing></legend><column><width>85</width><spacing>2</spacing><data_labels_text_color>FFFFFF</data_labels_text_color><data_labels_text_size>11</data_labels_text_size><data_labels_position>inside</data_labels_position><data_labels_always_on>1</data_labels_always_on><grow_time>0</grow_time><sequenced_grow>0</sequenced_grow><balloon_text>{value} {description}</balloon_text></column><depth>3</depth><angle>24</angle><line><bullet>round</bullet></line><labels><label lid=\"0\"><y>18</y><text_color>000000</text_color><text_size>13</text_size><rotate>1</rotate><align>center</align></label></labels>"
    settings += "<data>"
    settings += generate_report_graph_data(users, calls, type, graph_days)
    settings += "</data>"
    settings += "<graphs>"
    users.each do |user|
      settings += "<graph gid=\"#{user.id}\"><title>#{user.fullname}</title><color></color></graph>"
    end

    settings += "</graphs></settings>"
    
  end
  
  def generate_report_graph_data(users, calls, type, graph_days)
      
     x = Builder::XmlMarkup.new(:indent => 0)
     puts calls.class
     x.chart {
      x.series {
        calls.each do |group, call_data|
          x.value(group, :xid => group) 
        end
      }
      x.graphs{
        users.each do |user|
          x.graph(:gid => user.id){
            calls.each do |group, call_data|
              call_data = CdrEntries.by_ids(call_data.map{|c|c.id})
              if type == :duration
                x.value(call_data.for_extension(user.extension).sum(:billsec) / 60, :xid => group, :description => "minutes of calls for #{user.fullname} on #{group}")
              else
                x.value(call_data.for_extension(user.extension).count, :xid => group, :description => "calls for #{user.fullname} on #{group}")
              end
            end
          }
        end
      }
     }.to_s
  end

  
end
