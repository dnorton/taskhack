class AddCommentCounter < ActiveRecord::Migration
  def self.up
    add_column(:tasks, :comments_count, :integer, :default => 0, :null => false)
    Task.reset_column_information
    say_with_time "Updating Task.comments_count..." do
      Task.find(:all).each do |t|
        count = Task.count_by_sql("select count(*) from tasks t, comments c where c.task_id = t.id " +
          "and t.id = #{t.id}")
        t.comments_count = count
        t.save! 
      end
    end
  end

  def self.down
    remove_column :tasks, :comments_count
  end
end
