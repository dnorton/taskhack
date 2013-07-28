class Task < ActiveRecord::Base
  #lots of acts
  acts_as_taggable
  acts_as_list :scope => :project
  acts_as_ferret :fields => ['name', :uid, :project_title, :is_completed, :tl]

  belongs_to :project
  has_many :comments,
           :order => "created_at"

  def started?
	return ! self.started_at.nil?
  end

  def stop(time=Time.now)
    self.disable_ferret(:once)
    append = 0
    unless self.started_at.blank?
		  append = time - self.started_at 
	  end
		self.total_time = self.total_time + append
		self.started_at = nil;
		save!
  end
  
  def complete
      self.stop(Time.now)
      if self.completed_on.nil?
        self.completed_on = Time.now
      else
        self.completed_on = nil
      end
  end
  
  def completed?
      self.completed_on != nil
  end
  
  def running_time
    if self.started?
      Time.now - self.started_at
    else
      0
    end
  end
	
  def time_in_hours_minutes
    time = self.total_time
    hours = (time/SECONDS_IN_HOUR).floor
    time -= hours * SECONDS_IN_HOUR
    minutes = (time/SECONDS_IN_MINUTE).ceil
    return { :hours => hours, :minutes => minutes }
  end
    
  def hours
    return time_in_hours_minutes[:hours]
  end
  
  def minutes
    return time_in_hours_minutes[:minutes]
  end
  
  def format_time_string
    timestr = ''
    time = self.time_in_hours_minutes
    hours = time[:hours]
   if hours > 0
      timestr += "#{hours} "
      timestr += hours == 1 ? "hour, " : "hours, "
   end
	minutes = time[:minutes]
	if minutes > 0
      	timestr += "#{minutes} "
      	timestr += minutes == 1 ? "minute" : "minutes"
    end
	if timestr == ''
		timestr = "0 minutes"
	end
	return timestr
  end
  
  def update_time(hours, minutes)
    hours ||= "0"
    minutes ||= "0"
    
    if (hours.is_a? String) && 
      (minutes.is_a? String)
      self.total_time = hours.to_i * SECONDS_IN_HOUR + minutes.to_i * SECONDS_IN_MINUTE
    end
  end
  
  # logic to remove the due date and reminder date
  def remove_due_date
    self.due_at = nil
  	if ! self.reminder_at.nil?
	   self.reminder_at = nil
   end
  end
  
  # update the due date.  If reminder_at is not null, update it
  # due_date is a String
  def update_due_date(due_date)
    due = due_date.to_time
    if !self.reminder_at.nil?
        reminder_in_seconds = self.due_at - self.reminder_at
        self.reminder_at = due - reminder_in_seconds
        if self.project.user.email_flag?
          QueuedMessage.remove(self) 
          QueuedMessage.add(self)
        end
    end
    self.due_at = due        
  end
  
  # alias for comments_count
  def count_comments
      self.comments_count
  end
    
  #search specific instance methods
  def uid
    self.project.user_id
  end
  
  def pid
    self.project_id
  end
  
  def project_title
    self.project.title
  end
  
  def is_completed
    self.completed?().to_s
  end    
  
  alias :tl :tag_list
  def tag_with(tags)
    arr = tags.split.join(", ")
    self.tag_list = arr
  end

end
