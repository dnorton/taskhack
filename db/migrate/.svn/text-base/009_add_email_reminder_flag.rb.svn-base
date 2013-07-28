class AddEmailReminderFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :email_flag, :boolean, :default => false
    
  end

  def self.down
    drop_column :users, :email_flag
  end
end
