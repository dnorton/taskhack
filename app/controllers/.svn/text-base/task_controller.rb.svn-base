class TaskController < ApplicationController
  before_filter :login_required
  before_filter :check_due_reminders
  layout 'tasklayout'

  def new
    if request.xhr?
      @project = nil
      unless session[:project_id].nil?
        @project = Project.find(session[:project_id])
      end
      logger.warn("what is the project " + @project)
      render(:partial => 'new')
    end
  end
  
  def add
    @project = nil
    logger.warn(params)
    if params[:project].nil? || params[:project][:id].nil?
      @project = session[:user].projects.find(:first)
    else
      @project = session[:user].projects.find(params[:project][:id])
    end
    task = Task.new(params['task'])
    # move all tasks down 1 position
    @project.tasks << task
    task.move_to_top
    @project.save!
    task.save!
    flash[:action_status] = {
      :message => 'added',
      :task => task
    }
    stop = false
    if @project.id == session[:project_id]
      render(:partial => 'task', :object => task, :layout => false,
        :locals => {:stop => stop})    
    else
      render(:nothing => true)
    end
  end
  
  def index
    redirect_to(:action => 'list')
    @task
    if (!params[:id].blank?)
      @task = Task.find_by_contents("id:#{params[:id]} uid:#{session[:user].id}")
    end
  end
  
  def show
    session[:open_uri] = request.env['REQUEST_URI']	
    @task = nil
    if (!params[:id].blank?)
      @reminder = Reminder.new
      @task = Task.find_by_contents("id:#{params[:id]} uid:#{session[:user].id}")[0]
      @title = @task.name
      @project = @task.project
    end
    
  end

  def list
    session[:open_uri] = request.env['REQUEST_URI']	
    @project = session[:user].projects.find(:first)
    @title = "Task Inbox"
    session[:project_id] = @project.id
    session[:open_id] = Array.new if session[:open_id].nil?
    @active_tasks = @project.active_tasks	
    @active_total = sum_times(@active_tasks)
    @complete_tasks = @project.complete_tasks	
    @complete_total = sum_times(@complete_tasks)    
  end

  #TODO: make this more dynamic - should be accessible via Ajax
  # or non Ajax call
  def remove
    task = Task.find(params[:id])
    project = task.project
    Task.destroy(params[:id])
    if (session[:open_uri].nil? || session[:open_uri] =~ /show/)
      redirect_to(:controller => 'project', :action => 'show', :id => project.id)
    else
      redirect_to(session[:open_uri])
    end
  end
  
  def details
    @reminder = Reminder.new
    task = Task.find(params[:id])
    if request.xhr?
      render(:partial => 'details', :object => task, :layout => false)
    end
  end

  def summary
    @reminder = Reminder.new
    task = Task.find(params[:id])
    if request.xhr?
      render(:partial => 'task/summary', :object => task, :layout => false)
    end
  end
  
  
  def total_time
    @task = Task.find(params[:id])
    if request.xhr?
      render(:partial => 'total_time', :object => @task, :layout => false)
    end
  end

  def toggle_check
    task = Task.find(params[:id])
    #task.toggle!(:completed)
    #task.completed = !task.completed?
    unless task.completed?
      task.complete
      QueuedMessage.remove(task) if session[:user].email_flag? && ! task.reminder_at.nil?  	
    else
      task.completed_on = nil;
    end
  
    if task.save!
      if (session[:open_uri].nil?)
      	redirect_to(:controller => 'project', :action => 'show', :id => task.project.id)
      else
        redirect_to(session[:open_uri])
      end
    else
      render_text("D'oh")
    end
  end

  def start
    @task = Task.find(params[:id])
    @task.started_at = Time.now
    @task.disable_ferret(:once)  	
    @task.save!	
    if request.xhr?
      if (params[:details])
        render(:partial => 'task/details', :object => @task, :layout => false)
      else
        render(:partial => 'task/summary', :object => @task, :layout => false)
      end
    else
      redirect_to(:action => 'index')
    end
  end

  def stop
    
    @task = Task.find(params[:id])
    @task.stop(Time.now)
    @task.disable_ferret(:once)
    @task.save!
  	
    if request.xhr?
      if (params[:details])
        render(:partial => 'task/details', :object => @task, :layout => false)
      else
        render(:partial => 'task/summary', :object => @task, :layout => false)
      end
    else
      redirect_to(:action => 'list')
    end
  end
  
  def cancel
    @task = Task.find(params[:id])
    render(:partial => 'task', :object => @task,
      :locals => { :stop => true })
  end
  
  def save
    expire_fragment(:controller => 'tag', :action => 'list', :id => session[:user].id)
    @task = Task.find(params[:id])
    tags = params[:tags] || ''
    @task.tag_with(tags)    
    @task.update_attribute(:name, params[:task][:name])
    @task.update_time(params[:task][:hours], params[:task][:minutes])
    @reminder = Reminder.new
    if (!params[:project].nil?)
      @project = session[:user].projects.find(params[:project][:id])
      @task.project = @project
    end
    if (!params[:task][:due_at].blank?)
      due_date = params['task']['due_at']
      @task.update_due_date(session[:user].to_utc(due_date.to_time))
    else
      @task.due_at = nil
      unless @task.reminder_at.nil?
        @task.reminder_at = nil
        QueuedMessage.remove(@task) if session[:user].email_flag?
      end
    end      
    @task.save!
    render(:partial => 'task/details', :object => @task, :layout => false)
  end
  
  # show comments (this will be a partial called
  # via ajax soon)
  # TODO: make ajax call to display comments (third column)
  def comments
    @task = Task.find(params[:id])
    @comments = @task.comments
    if request.xhr?
      render(:partial => 'comments', :layout => false)
    end
  end
  
  def new_comment
    @task = Task.find(params[:id])
    @task.comments.create(:comment => params['comment']['comment'])
    @comments = @task.comments
    render(:partial => 'comments', :layout => false)
  end
  
  def edit_comment
    @comment = Comment.find(params[:id])
    @task = @comment.task
    render(:partial => 'edit_comment', :object => @comment)
  end
  
  def save_comment
    @comment = Comment.find(params[:id])
    @task = @comment.task
    @comments = @task.comments
    if ! params[:comment].nil?
      @comment.update_attribute(:comment, params[:comment][:comment])
      @comment.save!
    end
    render(:partial => 'comments', :layout => false)
  end
  
  def delete_comment
    @comment = Comment.find(params[:id])
    @task = @comment.task
    if @comment.destroy
      @comments = @task.comments
      render(:partial => 'comments', :layout => false)
    end
  end

  def edit
    @task = Task.find(params[:id])
    @project = @task.project
    @projects = session[:user].projects
    if request.xhr?
      render(:partial => 'edit', :object => @task, :layout => false)
    elsif request.post?
      if (!params[:task].nil? && !params[:task][:name].nil?) 
        @task.update_attribute(:name, params[:task][:name])
      end
      if (!params[:task].nil?)
        @task.update_time(params[:task][:hours], params[:task][:minutes])
      end        
      @task.save!
      render(:partial => 'task', :object => @task,
        :locals => { :stop => true })
        
    end
  end
  
  def update_comment_count
    @task = Task.find(params[:id])
    if request.xhr?
      render(:partial => 'comment_link', :object => @task)
    end
  end
  
  # TODO: use same controller method to 
  # render the form and submit the form changes
  def add_due_date
    @task = Task.find(params[:id])
    if (params[:task].nil? || params[:task][:due_at].nil?) 
      render(:partial => "task/add_due_date", :object => @task, :layout => false)
    else 
      @reminder = Reminder.new
      due_date = params['task']['due_at']
      @task.due_at = session[:user].to_utc(due_date)
      @task.save!
      #render(:partial => 'details') 
      render(:partial => "task/details", :object => @task, :layout => false)
    end
      
  end
  
  def edit_name
    @task = Task.find(params[:id])
    if params[:task].blank? || params[:task][:name].blank?
      render(:partial => 'task/edit_name', :object => @task, :layout => false)
    else
      @task.name = params[:task][:name]
      @task.save!
      render(:partial => 'summary', :object => @task, :layout => false)
    end
  end
  
  def edit_tags
    expire_fragment(:controller => 'tag', :action => 'list', :id => session[:user].id)
    @task = Task.find(params[:id])
    tags = params['tags'] || ''
    @task.tag_with(tags)
    @task.save!
    render(:partial => 'task/details', :object => @task, :layout => false)

  end
  
  def edit_project
    @task = Task.find(params[:id])
    @task.update_attribute(:project_id, params[:project][:id])
    @task.save!
    render(:partial => 'details', :object => @task, :layout => false)
  end
  
  def set_tags
    @task = Task.find(params[:id])
    render(:partial => 'set_tags', :object => @task, :layout => false)
  end
  
  def add_comment
    @task = Task.find(params[:id])
    render(:partial => 'add_comment', :object => @task, :layout => false)
  end
  
  def remove_due_date
    @reminder = Reminder.new
    @task = Task.find(params[:id])
    unless @task.reminder_at.nil?
      QueuedMessage.remove(@task) if session[:user].email_flag?
    end
    @task.remove_due_date
    @task.save!
    render(:partial => 'details', :object => @task, :layout => false)
  end 
  

  # add reminders that will notify the user a certain time 
  # before the due date
  def add_reminder_date
    @reminder = Reminder.new
    @task = Task.find(params[:id])
    if request.post? || request.xhr?
      @reminder.time = params[:reminder][:time].to_i
      @reminder.units = params[:reminder][:units]
      @task.reminder_at = @reminder.calculate_time(@task.due_at)
      @task.save!
      QueuedMessage.add(@task) if session[:user].email_flag?
      render(:partial => 'details', :object => @task, :layout => false)
    end
  end

  def remove_reminder
    @reminder = Reminder.new
    @task = Task.find(params[:id])
    @task.reminder_at = nil
    @task.save!
    QueuedMessage.remove(@task) if session[:user].email_flag?
    render(:partial => 'details', :object => @task, :layout => false)
  end 
  
  # ajax call to render the running time of a task
  def running_time
    @task = Task.find(params[:id])
    @running_time = @task.running_time
    render(:partial => 'running_time')
  end
  
  def action_status
    @action_status = flash[:action_status]
    render(:partial => 'task/action_status', :layout => false)
  end
  
  # change project on new task form
  def change_project
    @projects = session[:user].projects
    render(:partial => 'task/change_project', :layout => false)
  end
  
end
