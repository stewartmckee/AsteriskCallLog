require 'fastercsv'

class CdrEntriesController < ApplicationController
  # GET /cdr_entries
  # GET /cdr_entries.xml
  def index

    @columns = %w[accountcode src dst dcontext clid channel dstchannel lastapp lastdata start answer end duration billsec disposition amaflags]
    @display_columns = %w[src dst start billsec]
    @extension = params[:extension]
    @start_date = Date.parse(params[:start_date]) unless params[:start_date].nil?
    @data = []

    (0..6).each do |d|
      date = Date.today-d.days
      if date.strftime("%A") == "Monday"
        @last_monday_date = date
        break
      end
    end
    @start_date = @last_monday_date if @start_date.nil?

    
    FasterCSV.foreach('Master.csv') do |row|
      values = {}
      counter = 0
      record_date = DateTime.strptime(row[9], '%Y-%m-%d %H:%M:%S')
      puts record_date
      if row[1] == @extension and record_date >= @start_date and record_date < @start_date+7.days
        @columns.each do |column_name|
          if column_name == "start" or column_name == "answer" or column_name == "end"
            values[column_name.to_sym] = DateTime.strptime(row[counter], '%Y-%m-%d %H:%M:%S') unless row[counter].nil?

          elsif column_name == "billsec"
            values[column_name.to_sym] = row[counter].to_i
          else
            values[column_name.to_sym] = row[counter]
          end
          counter += 1
        end
        puts values.inspect
        @data << values
      end
    end

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
end
