class Reminder
		
	#TODO: add conversion method to calculate the time
	# for the reminder
	attr_accessor :time, :units

	def calculate_time(due_date)
		due_date - self.time.send(self.units)
	end
	
	def rtime
	   REMINDER_TIMES
	end

end
