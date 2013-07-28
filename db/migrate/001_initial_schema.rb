class InitialSchema < ActiveRecord::Migration
  def self.up
  create_table "comments"  do |t|
    t.column "task_id", :integer
    t.column "comment", :text, :default => "", :null => false
    t.column "created_at", :timestamp, :limit => 14
  end

  create_table "projects" do |t|
    t.column "user_id", :integer, :default => 0, :null => false
    t.column "title", :string, :limit => 150
    t.column "created_on", :datetime
    t.column "started_at", :datetime
    t.column "expected_complete_date", :datetime
    t.column "completed_at", :datetime
  end


  create_table "tasks"  do |t|
    t.column "user_id", :integer
    t.column "project_id", :integer
    t.column "name", :string, :limit => 120
    t.column "created_on", :datetime
    t.column "started_at", :datetime
    t.column "completed", :integer, :limit => 4, :default => 0, :null => false
    t.column "completed_on", :datetime
    t.column "total_time", :float, :default => 0.0, :null => false
    t.column "position", :integer, :default => 0, :null => false
  end

  add_index "tasks", ["project_id"], :name => "project_id"

  create_table "users" do |t|
    t.column "login", :string, :limit => 20
    t.column "display_name", :string, :limit => 80
    t.column "email_address", :string, :limit => 80
    t.column "password", :string, :limit => 40
  end
  end

  def self.down
	drop_table :comments
	drop_table :tasks
	drop_table :projects
	drop_table :users
  end
end
