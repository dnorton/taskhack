# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	# constants
	# SECONDS_IN_DAY = 86400
	# SECONDS_IN_HOUR = 3600
	# SECONDS_IN_MINUTE = 60

	# convert a float representing a time difference in days, hours, minutes, and seconds
	# TODO: add options (for instance - add ability to exclude seconds)
	def human_time(time)
		timestr = ''
		hoursstr = nil
		minstr = nil
		timeary = Array.new
		hours = (time / SECONDS_IN_HOUR).floor
		if hours > 0
			time -= (hours * SECONDS_IN_HOUR)
			hoursstr = "#{hours} "
			hoursstr += hours == 1 ? "hour" : "hours"
			timeary << hoursstr
		end
		minutes = (time / SECONDS_IN_MINUTE).floor
		if minutes > 0
			time = time - (minutes * SECONDS_IN_MINUTE)
			minstr = "#{minutes} "
			minstr += minutes == 1 ? "minute" : "minutes"
			timeary << minstr
		end
		if hoursstr.nil? && minstr.nil?
			timestr = "0 minutes"
		else
		  timestr = timeary.join(", ")
		end
		return timestr
	end

	# convert a float into "00:00" hours/minutes
	# TODO: I need to figure out how to combine the two helper methods
	# maybe pass to some sort of Options object
	def print_hours_minutes(time)
		timestr = ''
		hours = ((time + 1) / SECONDS_IN_HOUR).floor
		if hours > 0
			time = time - (hours * SECONDS_IN_HOUR)
		end
		minutes = (time / SECONDS_IN_MINUTE).floor % SECONDS_IN_MINUTE
		if minutes > 0
			time = time - (minutes * SECONDS_IN_MINUTE)
		end
		seconds = time 
		return sprintf("%02dh %02dm",hours, minutes)
	end

	def display_name
		unless session[:user].nil?
			unless session[:user].display_name.nil?
				session[:user].display_name	
			else
				session[:user].login
			end
		end	
	end

end
