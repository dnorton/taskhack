class AccountController < ApplicationController
  layout  'taskman'

  def login
    redirect_url = session[:open_uri] || request.request_uri
    if request.post?
      @user = User.authenticate(params[:user_login], params[:user_password])
      
      # user logged in directly
      if session[:user].blank? && !@user.blank?
        session[:user] = @user
        flash['notice']  = "Login successful"
        redirect_url = '/task/inbox'
        # user logged in through OpenId
        # copy the openid_url to the session logged in user
        # and delete the OpenID user
      elsif !session[:user].blank? && !@user.blank? &&
          !session[:new_id].blank? && session[:new_id]
        !session[:user].openid_url.blank?
        @user.openid_url = session[:user].openid_url
        @user.save!
        User.destroy(session[:user].id)
        session[:user] = @user
        session[:new_id] = false
        flash['notice']  = "Login successful"
        redirect_url = '/task/inbox'
      else
        flash.now['notice']  = "Login unsuccessful"
      end
      redirect_back_or_default redirect_url
    end
    
  end
  
  def signup
    unless (params[:user].nil?)
      @user = User.new(params[:user])

      
      if request.post? and @user.save!
        session[:user] = User.authenticate(@user.login, params[:user][:password])
        session[:user].email_flag = params[:user][:email_flag] unless params[:user][:email_flag].nil?
        session[:user].projects << Project.new(:title => "Inbox")
        session[:user].save!
        flash[:notice]  = "Signup successful"
        redirect_back_or_default :controller => 'project', :action => 'list'
      end      
    end
  end
  
  def info
    @title = "User Information"
    @user = session[:user]
  end  
  
  def edit
    redirect_url = request.request_uri
    @title = "Edit User Information"
    @user = session[:user]
    if request.post? && !params[:user].blank?
      begin
        User.transaction do
          @user.update_attribute(:email_flag, params[:user][:email_flag])
          @user.update_attribute(:display_name, params[:user][:display_name])
          @user.update_attribute(:login, params[:user][:login]) if params[:user][:login]
          @user.update_attribute(:time_zone, params[:user][:time_zone])
          @user.tz = TimeZone[params[:user][:time_zone]]
          @user.save!
          redirect_url = '/account/info'
        end
      rescue Exception => err
        flash[:notice] = "error editing account: #{err.message}"
      end  
      redirect_to redirect_url
    end
  end
  
  def logout
    flash[:status] = nil  
    reset_session
  end
    
  def welcome
  end
  
  def get_time
    if session[:user]
      render :text => session[:user].to_local_time(Time.now).to_formatted_s(:top)
    end
  end
  
  # associate your OpenID url with an existing account
  def associate
    @user = session[:user]
    
  end
  
end
