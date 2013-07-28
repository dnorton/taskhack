class AddQueuedMessageTable < ActiveRecord::Migration
  def self.up
    create_table :queued_messages do |t|
      t.column :task_id, :integer, :default => 0, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :scheduled_at, :datetime, :null => false
      t.column :sent_at, :datetime
    end
    add_index :queued_messages, :task_id 
  end

  def self.down
    drop_table :queued_messages
  end
end
