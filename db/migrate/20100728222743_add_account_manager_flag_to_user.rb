class AddAccountManagerFlagToUser < ActiveRecord::Migration
  def self.up
      add_column :users, :account_manager, :boolean, :default => false
  end

  def self.down
      remove_column :users, :account_manager
  end

end
