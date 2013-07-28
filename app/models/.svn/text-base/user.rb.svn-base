require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

  has_many :projects
  
  composed_of :tz,
              :class_name => 'TimeZone',
              :mapping => %w(time_zone name)

  # Please change the salt to something else, 
  # Every application should use a different one 
  @@salt = 'change-me'
  cattr_accessor :salt

  validates_uniqueness_of :login 

  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40, :if => :password_required?
  validates_presence_of :login 
  validates_presence_of :password, 
			:password_confirmation,
			:if => :password_required? 
  # Authenticate a user. 
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    find(:first, :conditions => "login = '#{login}' AND password = '#{sha1(pass)}'")
  end  

  def has_past_due_reminders?
      return false if self.nil?
      count = self.class.count_by_sql(["select count(1) from users u, projects p, tasks t where u.id = p.user_id and p.id = t.project_id and u.id = '?' and t.reminder_at < ? and t.completed_on is NULL",
      self.id, Time.now ])
      count > 0
  end
  
  def find_past_due_reminders
      return nil if self.nil?
      self.class.find_by_sql(["select t.*, p.title from users u, projects p, tasks t where u.id = p.user_id and p.id = t.project_id and u.id = '?' and t.reminder_at < ? and t.completed_on is NULL",
      self.id, Time.now])
  end
  
  def to_utc(time)
    unless time.nil?
      self.tz.unadjust(time)
    end
  end
  
  def to_local_time(time)
    unless time.nil?
      self.tz.adjust(time)
    end
  end
  
  
  # starts the protected method section 
  protected

  # Apply SHA1 encryption to the supplied password. 
  # We will additionally surround the password with a salt 
  # for additional security. 
  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end
    
  before_create :crypt_password
  
  # Before saving the record to database we will crypt the password 
  # using SHA1. 
  # We never store the actual password in the DB.
  def crypt_password
    write_attribute "password", self.class.sha1(password)
  end
  
  before_update :crypt_unless_empty
  
  # If the record is updated we will check if the password is empty.
  # If its empty we assume that the user didn't want to change his
  # password and just reset it to the old value.
  def crypt_unless_empty    
    #if password.empty?      
    #if ! password_required?      
      #user = self.class.find(self.id)
      #self.password = user.password
    #else
    if password_required?
      write_attribute "password", self.class.sha1(password)
    end        
  end
  
  # the password is not required if the openid_url is NOT blank
  # or the password is already set and has not changed 
  # TODO: simply the logic here... this should be much more concise
  def password_required?
      # return true if self.nil? or self.id.blank?
    password_required = true
    if (!self.openid_url.blank?)
      password_required = false
    end
    if (password_required and !self.id.nil?)
      user = self.class.find(self.id) 
      password_required = user.nil? || (user.password != password)
    end
    return password_required
  
  end
  
  
end
