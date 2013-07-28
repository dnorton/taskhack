class QueuedMessage < ActiveRecord::Base
  
  def QueuedMessage.add(task)
    qm = QueuedMessage.new
    qm.task_id = task.id
    qm.scheduled_at = task.reminder_at
    qm.save!
  end
  
  def QueuedMessage.remove(task)
    qm = QueuedMessage.find(:first, :conditions => ["task_id = ?", task.id])
    unless qm.nil?
      QueuedMessage.delete(qm.id)
    end
  end
  
  def QueuedMessage.pop
    messages = QueuedMessage.find(:all, :conditions => ["scheduled_at < ? and sent_at is NULL", Time.now])
  end
end