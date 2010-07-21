class CdrEntriesController < ApplicationController
  before_filter :login_required

  def index

    @extension = params[:extension]
    @user = User.find_by_extension(@extension)
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
      format.xml  { render :xml => @cdr_entries }
    end
  end

  # GET /cdr_entries/1
  # GET /cdr_entries/1.xml
  def show
    @cdr_entries = CdrEntries.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cdr_entries }
    end
  end

  # GET /cdr_entries/new
  # GET /cdr_entries/new.xml
  def new
    @cdr_entries = CdrEntries.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cdr_entries }
    end
  end

  # GET /cdr_entries/1/edit
  def edit
    @cdr_entries = CdrEntries.find(params[:id])
  end

  # POST /cdr_entries
  # POST /cdr_entries.xml
  def create
    @cdr_entries = CdrEntries.new(params[:cdr_entries])

    respond_to do |format|
      if @cdr_entries.save
        flash[:notice] = 'CdrEntries was successfully created.'
        format.html { redirect_to(@cdr_entries) }
        format.xml  { render :xml => @cdr_entries, :status => :created, :location => @cdr_entries }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cdr_entries.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cdr_entries/1
  # PUT /cdr_entries/1.xml
  def update
    @cdr_entries = CdrEntries.find(params[:id])

    respond_to do |format|
      if @cdr_entries.update_attributes(params[:cdr_entries])
        flash[:notice] = 'CdrEntries was successfully updated.'
        format.html { redirect_to(@cdr_entries) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cdr_entries.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cdr_entries/1
  # DELETE /cdr_entries/1.xml
  def destroy
    @cdr_entries = CdrEntries.find(params[:id])
    @cdr_entries.destroy

    respond_to do |format|
      format.html { redirect_to(cdr_entries_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def phone_as_string(number)
    @default_country = "44"
    @default_code = "141"
    
    @international = false
    @national = false
    @local = false
    
    
    if number.starts_with?("00") or number.starts_with?("+")
      @international = true
    end
    
    
    
  end
end
