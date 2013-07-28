class TagController < ApplicationController
  
  before_filter :login_required
  
  layout 'taskman'
	
  
  def list
    @time = Time.now
    if request.xhr?
      render(:partial => 'list', :layout => false)
    end
  end
  
  # delete only the taggings associated with the user
  def remove
    @tagparam = params[:tag]
    @tag = Tag.find(:first, :conditions => ["name = ?", @tagparam])
    @tasks = Task.find_tagged_with(@tagparam, :conditons => user_condition)
    Task.transaction do
      @tasks.each do |@task|
        tl = @task.tag_list
        tl = tl.delete(@tagparam)
        @task.tag_with(tl)
        @task.save!
      end
    end
    Tagging.destroy_all(["user_id = ? and tag_id = ?", session[:user].id, @tag.id])
    expire_fragment(:controller => 'tag', :action => 'list', :id => session[:user].id)    
    flash[:notice] = "tag #{@tagparam} was deleted"
    redirect_to('/tags')
  end
  
  def show
    session[:open_uri] = request.env['REQUEST_URI']
    session[:project_id] = nil
    session[:open_id] = Array.new if session[:open_id].nil?    
    @tag = params[:tag] || ''
    @title = "tag: #{@tag}"
    session[:open_tags] = @tag
    @active_tasks = []
    @completed_tasks = []
    @tasks = Task.find_by_contents("tl:#{@tag} uid:#{session[:user].id}")
    @tasks.each do |task|
      if task.completed?
        @completed_tasks << task
      else
        @active_tasks << task
      end
    end
    @completed_tasks = @completed_tasks.sort{|x,y| y.created_on <=> x.created_on}
    @active_tasks = @active_tasks.sort{|x,y| y.created_on <=> x.created_on}
    @active_total = sum_times(@active_tasks)              	
    @completed_total = sum_times(@completed_tasks)
                
  end
  
  private
  def user_condition
    "project_id in (select project_id from projects p where " +
      "user_id = #{session[:user].id})"
  end
  
end
