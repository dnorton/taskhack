class RemindersController < ApplicationController

  before_filter :login_required 

  def check_past_due
    @has_reminders = session[:user].has_past_due_reminders?
    render(:partial => 'check_past_due')
  end

  def show
    @tasks = session[:user].find_past_due_reminders
  end
  
  def task
    @reminder = Reminder.new
    task = Task.find(params[:id])
    if request.xhr?
      render(:partial => 'reminders/task', :object => task, :layout => false)
    end
    
  end
end
