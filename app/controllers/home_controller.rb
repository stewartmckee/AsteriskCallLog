class HomeController < ApplicationController
  before_filter :login_required

  def index

    @extension = current_user.extension
    @start_date = DateTime.parse(params[:start_date]) unless params[:start_date].nil?
    (0..6).each do |d|
      date = Date.today-d.days
      if date.strftime("%A") == "Monday"
        @last_monday_date = date
        break
      end
    end
    @start_date = @last_monday_date if @start_date.nil?
    
    @data = CdrEntries.exclude_s.for_extension(@extension).after(@start_date).before(@start_date + 7.days)
    
    @data.each do |cdr|
      cdr.src = "Incoming Call" if cdr.dst == cdr.src
    end
    
    @incoming = @data.incoming(@extension)
    @outgoing = @data.outgoing(@extension)
    
    @grouped_data = @data.group_by{|entry| entry.calldate.strftime("%A")}
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @homes }
    end
  end

end
