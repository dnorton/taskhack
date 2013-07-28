class Project < ActiveRecord::Base
  belongs_to :user
  has_many :tasks, 
    :order => :position,
    :dependent => :destroy
  
  before_destroy :block_default
  
  def active_tasks
    self.tasks.find(:all,
                    :conditions => "completed_on is null",
                    :order => 'position')
  end
  
  def complete_tasks
    self.tasks.find(:all,
                    :conditions => "completed_on is not null",
                    :order => 'created_on DESC')
  end
	
  def has_running_tasks?
  	count = self.tasks.count(:conditions => ["completed_on is null and started_at is not NULL"])	
  	return count != 0
  end
  
  def running_tasks
    running_tasks = self.active_tasks.select {|task| 
      task.started?
    }
    puts running_tasks.length unless running_tasks.nil?
    return running_tasks
  end

  def formatted_due_date
    unless self.expected_complete_date.blank?
      self.expected_complete_date.to_formatted_s(:default)  
    end
  end
  
  def count_active_tasks
#      Task.count("project_id = #{self.id} and completed_on is null")
       Task.count(:conditions => 
           "project_id = #{self.id} and completed_on is null")
  end
  
  def count_complete_tasks
      Task.count(:conditions => 
          "project_id = #{self.id} and completed_on is not null")
  end

  def is_default?
    first = Project.find(:first, :conditions => ["user_id = ?", self.user_id], :order => "created_on asc")
    id == first.id
  end
  
  private
  def block_default
      if self.id == Project.find(:first, :conditions => ["user_id = ?", self.user_id]).id
        raise "Cannot delete project #{self.id}"
      end
  end
end
  
