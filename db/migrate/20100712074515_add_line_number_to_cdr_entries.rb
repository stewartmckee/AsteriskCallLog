class AddLineNumberToCdrEntries < ActiveRecord::Migration
  def self.up
      add_column :cdr_entries, :line_number, :integer
  end

  def self.down
      remove_column :cdr_entries, :line_number
  end
end
