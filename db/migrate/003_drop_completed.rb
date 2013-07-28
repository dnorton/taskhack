class DropCompleted < ActiveRecord::Migration
  def self.up
	remove_column :tasks, :completed
  end

  def self.down
	add_column :tasks, :completed, :boolean, :default => 0
  end
end
