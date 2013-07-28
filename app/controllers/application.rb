# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require_dependency "login_system"

class ApplicationController < ActionController::Base
  include LoginSystem
  #model :user
  #model :task
  #model :project
	
  before_filter :access_tags
  after_filter :setup_page
	

  protected
  def sum_times(tasks)
    total = 0.0
    tasks.each do |task|
      total += task.total_time
      if (task.started?) 
        total += task.running_time
      end
    end
    total
  end
	
  def check_due_reminders
    if ! session[:user].nil? && session[:user].has_past_due_reminders?
      flash[:status] = true
    else
      flash[:status] = nil 
    end
  end
	
  def access_tags
    unless session[:user].nil?
      unless read_fragment(:controller => 'tag', :action => 'list', :id => session[:user].id)
        @taggings = Tagging.find(:all, :conditions => taggings_condition)

#        @taggings = Tagging.find(:all, :conditions => user_condition)
        @tags = @taggings.collect{|tagging| tagging.tag }.uniq.sort!{|x,y| x.name <=> y.name}
      end
    end	
  end
	
  def setup_page
    if @title.nil?
      @title = "TaskHack"
    else
      @title = @title
    end
  end

  def user_condition
    "project_id in (select project_id from projects p where " +
      "p.user_id = #{session[:user].id})"
  end
  
  def taggings_condition
    "taggable_type = 'Task' and taggable_id in (select t.id from " + 
            "tasks t, projects p, users u where t.project_id = p.id and p.user_id = #{session[:user].id})"
  end
  
	
end
