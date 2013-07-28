
class SearchController < ApplicationController
  
  before_filter :login_required
	before_filter :check_due_reminders

	layout 'taskman'

  def index
      @title = nil
      "Search results for #{params[:q]}"
      @tasks = nil
      unless (params[:q].blank?) 
        @title ="Search results for #{params[:q]}"
        
        @tasks = Task.find_by_contents(params[:q] + " uid:#{session[:user].id}" + 
                                       " is_completed:false",
                                      :num_docs => :all, :limit => nil)
      else
        @title = "tags"
#        @taggings = Tagging.find(:all, :conditions => ["user_id = ?", session[:user].id])
        @taggings = Tagging.find(:all, :conditions => taggings_condition)

        @tags = @taggings.collect{|tagging| tagging.tag }.uniq
        
      end
  end
  
  #search completed tasks
  def completed
    unless (params[:q].blank?)
      @tasks = Task.find_by_contents(params[:q] + " uid:#{session[:user].id}" +
                                    " is_completed:true",
                                    :num_docs => :all, :limit => nil)
    end
    render(:partial => 'completed', :layout => false)
  end

  def tags
    session[:open_uri] = request.env['REQUEST_URI']
    session[:project_id] = nil
    session[:open_id] = Array.new if session[:open_id].nil?    
    @tag = params[:tag] || ''
    @title = "tag: #{@tag}"
    session[:open_tags] = @tag
    @active_tasks = Task.find_by_contents("tl:\"#{@tag}\" uid:#{session[:user].id}" +
                                  " is_completed:false",
                :num_docs => :all, :limit => nil).sort {|x,y| y.created_on <=> x.created_on }
    @active_total = sum_times(@active_tasks)              	
    @completed_tasks = Task.find_by_contents("tl:\"#{@tag}\" uid:#{session[:user].id}" +
                                  " is_completed:true",
                :num_docs => :all, :limit => nil).sort {|x,y| y.created_on <=> x.created_on }
    @completed_total = sum_times(@completed_tasks)
                
  end

  def export
  end
end
