require 'fastercsv'
require 'ftools'

class CdrEntries < ActiveRecord::Base
  
  named_scope :for_extension, lambda {|extension|{:conditions => ["src = ? or dst = ?", extension, extension], :order => "calldate desc"}}
  named_scope :exclude_s, lambda {{:conditions => "dst <> 's'"}}
  named_scope :before, lambda {|date| {:conditions => ["calldate < ?", date]}}
  named_scope :after, lambda {|date| {:conditions => ["calldate > ?", date]}}
  
  named_scope :incoming, lambda {|exten| {:conditions => ["dst = ?", exten]}}  
  named_scope :outgoing, lambda {|exten| {:conditions => ["src = ? and not dst = ?", exten, exten]}}  
  
  def self.update_from_log

    @copied_file = File.join(File.dirname(__FILE__), '..', '..', 'master.csv')
    @working_file = File.join(File.dirname(__FILE__), '..', '..', 'working-master.csv')
    
    if !File.exists?(@working_file) or File.size(@working_file) != File.size(@copied_file)
      File.copy(@copied_file, @working_file)
    end
    
    entries = []
    
    FasterCSV.foreach(@working_file) do |row|
      unless CdrEntries.exists?(:uniqueid => row[16])
        entry = {}
        entry[:accountcode] = row[0] || ""
        entry[:src] = row[1] || ""
        entry[:dst] = row[2] || ""
        entry[:dcontext] = row[3] || ""
        entry[:clid] = row[4] || ""
        entry[:channel] = row[5] || ""
        entry[:dstchannel] = row[6] || ""
        entry[:lastapp] = row[7] || ""
        entry[:lastdata] = row[8] || ""
        entry[:calldate] = DateTime.strptime(row[9], '%Y-%m-%d %H:%M:%S') unless row[9].nil?
        entry[:answerdate] = DateTime.strptime(row[10], '%Y-%m-%d %H:%M:%S') unless row[10].nil?
        entry[:hangupdate] = DateTime.strptime(row[11], '%Y-%m-%d %H:%M:%S') unless row[11].nil?
        entry[:duration] = row[12].to_i || "0"
        entry[:billsec] = row[13].to_i || "0"
        entry[:disposition] = row[14] || ""
        entry[:uniqueid] = row[16] || ""
        
        entries << entry
      end
    end
    
    puts "Creating #{entries.length} entries"
    
    CdrEntries.create(entries)

  end
  
end
