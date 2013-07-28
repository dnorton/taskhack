class AddDueDate < ActiveRecord::Migration
  def self.up
	add_column :tasks, :due_at, :datetime
	add_column :tasks, :reminder_at, :datetime
  end

  def self.down
	remove_column :tasks, :due_at
	remove_column :tasks, :reminder_at
  end
end
