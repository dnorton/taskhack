class Notifier < ActionMailer::Base
  
  def reminder(task)
    @user = task.project.user
    @recipients = @user.email_address
    @subject = "Reminder: " + task.name + " due " + @user.to_local_time(task.due_at).to_formatted_s(:short_stamp) 

    body(
      'name' => @user.display_name,
      'task' => task,
      'user' => @user )
    @from = 'reminders@taskhack.com'
  end
  
end
