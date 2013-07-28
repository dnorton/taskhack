class AddUserTimeZone < ActiveRecord::Migration
  def self.up
    add_column :users, :time_zone, :string
    User.reset_column_information
    say_with_time "Updating User.time_zone..." do
      User.find(:all).each do |t|
        t.time_zone = 'Eastern Time (US & Canada)'
        t.save! 
      end
    end
  end

  def self.down
    drop_column :users, :time_zone
  end
end
