class UpdateTaggingsAddUserId < ActiveRecord::Migration
  def self.up
    add_column :taggings, :user_id, :integer, :default => 0, :null => false
    Tagging.reset_column_information
    Task.find(:all).each {|task|
        task.taggings.each {|tagging|
          unless task.project.nil? || task.project.user_id.nil?
            tagging.user_id = task.uid
            tagging.save!
          end
        }
      }
  end

  def self.down
    remove_column :taggings, :user_id
  end
end
