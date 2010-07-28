class ChangeExtensionOnUserToString < ActiveRecord::Migration
  def self.up
    change_column :users, :extension, :string
  end

  def self.down
    change_column :users, :extension, :integer
  end
end
