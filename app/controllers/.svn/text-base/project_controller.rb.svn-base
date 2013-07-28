class ProjectController < ApplicationController

  before_filter :login_required
  before_filter :check_due_reminders
  
  layout 'taskman'
  
  def new
    @title = 'New Project'
    if request.post?
      expire_fragment(:controller => 'project', :action => 'list', :id => session[:user].id)
      @project = Project.new(params['project'])
      @project.save!
      session[:user].projects << @project
      session[:user].save!
      redirect_to(:action => 'list')
    end 
  end

  def list
    @title = "Project List for " + session[:user].login
    session[:project_id] = nil
    default = session[:user].projects.find(:first)
    @project_list = session[:user].projects.find(:all, :conditions => ["id != ?", default.id])
  end
  
  def p_list
    @task = Task.find(params[:id])
    @project = @task.project
    @projects = session[:user].projects.find(:all)
    render(:partial => 'p_list', :layout => false)    
  end

  def edit
    @project = session[:user].projects.find(:first, :conditions => 
        ["id = ?",params[:id]])
    @title = @project.title
    if @project.nil? || @project.is_default?
      flash[:error_message] = "you cannot edit this project"
      redirect_to(:controller => 'home', :action => 'error')
    end
    if request.post?
      expire_fragment(:controller => 'project', :action => 'list', :id => session[:user].id)        
      @project.update_attribute(:title, params[:project][:title])
      @project.expected_complete_date = params[:project][:formatted_due_date]
      @project.save!
      redirect_to(:action => 'list')
    end
  end
  
  # allow edit tasks
  def edit_tasks
    @project = session[:user].projects.find(params[:id])
    @projects = session[:user].projects
    render(:partial => 'project/edit_tasks', :object => @project, :layout => false)
  end

  def index
    redirect_to(:action => 'list')
  end

  def remove
    expire_fragment(:controller => 'project', :action => 'list', :id => session[:user].id)            
    @project = Project.find(params[:id], :conditions => ["user_id = ?", session[:user].id])
    @project.tasks.destroy_all
    Project.destroy(@project.id)
    redirect_to(:controller => 'project', :action => 'list')
  end
  
  def show
    @project = session[:user].projects.find(:first, :conditions => 
        ["id = ?",params[:id]])
    session[:open_uri] = request.request_uri
    if @project.blank?
      flash[:error_message] = "you cannot view this project"
      redirect_to(:controller => 'home', :action => 'error')
    else
      session[:open_id] = Array.new if session[:open_id].nil?
      # redirect to task/list if the project is the default project
      default = session[:user].projects.find(:first)
      if @project.id == default.id
        redirect_to('/task/inbox')
      end
      
    end
    respond_to do |format|
      format.html { 
        @title = @project.title || "Project Tasks"
        session[:project_id] = @project.id
        @active_tasks = @project.active_tasks	
        @active_total = sum_times(@active_tasks)
        if session[:open_id].include?(@project.id)
          @completed_tasks = @project.complete_tasks	
          @completed_total = sum_times(@completed_tasks)
        end

      }
      format.xml { render :xml => @project.tasks.to_xml }
      format.json {render :json => @project.tasks.to_json}
    end
  end
  
  # Sort based on an ajax array with
  # task ids
  def sort
    @project = Project.find(params[:id])
    @project.active_tasks.each do |task|
      task.position = params['task_list'].index(task.id.to_s) + 1
      task.disable_ferret(:once)
      task.save
    end
    if request.post? || request.xhr?
      render :nothing => true
    end
  end
  
  # order the tasks - adding a new page to overcome AJAX issues
  # TODO: rename this
  def order
    @project = Project.find(params[:id])
    @title = "Sort " + @project.title
    @active_tasks = @project.active_tasks
    @active_total = sum_times(@active_tasks)
  end
  
  # format the active time based on a task id
  # TODO: move this to task_controller
  def active_time
    if request.xhr?
      @active_time = nil
      if session[:open_uri].blank? || session[:open_uri] !~ /tags/          
        @project = Task.find(params[:id]).project
        @active_time = sum_times(@project.active_tasks) 
      else 
        @tag = session[:open_tags]
        @active_tasks = []
        @tasks = Task.find_tagged_with_by_user(session[:user].id, @tag)
        @tasks.each do |task|
          @active_tasks << task if ! task.completed?
        end
        @active_time = sum_times(@active_tasks)
                        
      end
      render(:partial => 'active_time', :object => @active_time)
    end
  end
  
  # HACK: rename active_task once above is moved
  def project_active_time
    @active_time = nil
    if request.xhr?
      if session[:open_uri].blank? || session[:open_uri] !~ /tags/          
        @project = Project.find(params[:id])
        @active_time = sum_times(@project.active_tasks) 
      else 
        @tag = session[:open_tags]
        @active_tasks = []
        @tasks = Task.find_tagged_with_by_user(session[:user].id, @tag)
        @tasks.each do |task|
          @active_tasks << task if ! task.completed?
        end
        @active_time = sum_times(@active_tasks)
      end
      render(:partial => 'active_time', :object => @active_time)
    end
  end

  # export Tasks as a CSV file  
  def export
    @project = Project.find(params[:id])
    @tasks = @project.tasks(:order => 'task.completed')
    unless @tasks.nil? or @tasks.size <= 0
      content_type = if request.user_agent =~ /windows/i
        ' application/vnd.ms-excel'
      else
        ' text/csv'
      end
      CSV::Writer.generate(output = "") do |csv|
        csv << ['id', 'title', 'time in hours', 'creation date', 'completed_on']
        @tasks.each do |task|
          csv << [task.id, task.name, (task.total_time/3600).to_f, task.created_on, task.completed_on]
        end
      end
      send_data(output,
        :type => content_type,
        :filename => "#{@project.title.gsub(/\s/, '_')}.csv")
    end
  end

  def completed_tasks
    unless session[:project_id].nil?
      @id = session[:project_id]
      @project = Project.find(@id)
    end
#    @project = Project.find(session[:project_id]) unless session[:project_id].nil?
    unless @project.blank?
      session[:open_id] << @project.id
      @completed_tasks = @project.complete_tasks	
      @total = sum_times(@completed_tasks)
    end
    render(:partial => 'completed_tasks')
  end

  def hide_completed_tasks
    @project = Project.find(session[:project_id]) unless session[:project_id].nil?
    session[:open_id].delete_if {|x| x == @project.id} unless session[:open_id].nil? || @project.blank?
    unless @project.blank?  
      render :inline => "<p/><%= link_to_remote 'show completed tasks', :update => 'completed_tasks',
  					:url => {
  						:controller => 'project',
  						:action => 'completed_tasks',
  						:id => @project } %>"
    end
  end
    
end

