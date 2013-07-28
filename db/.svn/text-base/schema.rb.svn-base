# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "comments", :force => true do |t|
    t.integer   "task_id"
    t.text      "comment",    :default => "", :null => false
    t.timestamp "created_at",                 :null => false
  end

  create_table "open_id_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_nonces", :force => true do |t|
    t.string  "server_url", :default => "", :null => false
    t.integer "timestamp",                  :null => false
    t.string  "salt",       :default => "", :null => false
  end

  create_table "projects", :force => true do |t|
    t.integer  "user_id",                               :default => 0, :null => false
    t.string   "title",                  :limit => 150
    t.datetime "created_on"
    t.datetime "started_at"
    t.datetime "expected_complete_date"
    t.datetime "completed_at"
  end

  create_table "queued_messages", :force => true do |t|
    t.integer  "task_id",      :default => 0, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "scheduled_at",                :null => false
    t.datetime "sent_at"
  end

  add_index "queued_messages", ["task_id"], :name => "queued_messages_task_id_index"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "taggings", :force => true do |t|
    t.integer "taggable_id"
    t.integer "tag_id"
    t.string  "taggable_type"
    t.integer "user_id",       :default => 0, :null => false
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "name",            :limit => 120
    t.datetime "created_on"
    t.datetime "started_at"
    t.datetime "completed_on"
    t.float    "total_time",                     :default => 0.0, :null => false
    t.integer  "position",                       :default => 0,   :null => false
    t.datetime "due_at"
    t.datetime "reminder_at"
    t.integer  "comments_count",                 :default => 0,   :null => false
    t.string   "cached_tag_list"
  end

  add_index "tasks", ["user_id"], :name => "user_id"

  create_table "tests", :force => true do |t|
    t.string   "text",      :limit => 50
    t.datetime "test_date"
  end

  create_table "users", :force => true do |t|
    t.string  "login",         :limit => 20
    t.string  "display_name",  :limit => 80
    t.string  "email_address", :limit => 80
    t.string  "password",      :limit => 40
    t.boolean "email_flag",                  :default => false
    t.string  "time_zone"
    t.string  "openid_url"
  end

end
