# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

class OpenIdsController < ApplicationController
#  open_id_consumer :required => [:nickname], :optional => [:email, :timezone]
  
  layout 'taskman'
  

  def index
    @title = 'Welcome'
  end

  def begin
    # If the URL was unusable (either because of network conditions,
    # a server error, or that the response returned was not an OpenID
    # identity page), the library will return HTTP_FAILURE or PARSE_ERROR.
    # Let the user know that the URL is unusable.
    debugger 
    case openid_response.status
      when OpenID::SUCCESS
        # The URL was a valid identity URL. Now we just need to send a redirect
        # to the server using the redirect_url the library created for us.
    
        # redirect to the server
        redirect_to openid_response.redirect_url((request.protocol + request.host_with_port + '/'), url_for(:action => 'complete'))
      else
        flash[:error] = "Unable to find openid server for <q>#{params[:openid_url]}</q>"
        render :action => :index
    end
  end

  def complete
    case openid_response.status
      when OpenID::FAILURE
        # In the case of failure, if info is non-nil, it is the
        # URL that we were verifying. We include it in the error
        # message to help the user figure out what happened.
        if openid_response.display_identifier
          flash[:message] = "Verification of #{openid_response.display_identifier} failed. "
        else
          flash[:message] = "Verification failed. "
        end
        flash[:message] += openid_response.msg.to_s
    
      when OpenID::SUCCESS
        # Success means that the transaction completed without
        # error. If info is nil, it means that the user cancelled
        # the verification.
        flash[:message] = "You have successfully verified #{openid_response.display_identifier} as your identity."
        if open_id_fields.any?
          flash[:message] << "<hr /> With simple registration fields:<br/>"
          open_id_fields.each {|k,v| flash[:message] << "<br /><b>#{k}</b>: #{v}"}
        end
        redirect_url = "/task/inbox"
        @user = User.find_by_openid_url(openid_response.display_identifier)
        if @user.nil?
          session[:user] = User.new(:login => openid_response.display_identifier,
                                    :openid_url => openid_response.display_identifier)
          session[:user].projects << Project.new(:title => "Inbox")
          session[:user].save!
          session[:new_id] = true
          redirect_url = "/account/associate"
          # redirect_to :controller => 'account', :action=> 'associate'
        else
          session[:user] = @user
          redirect_url = "/task/inbox"
          # redirect_to :controller => 'task', :action => 'inbox'
        end
      when OpenID::CANCEL
        flash[:message] = "Verification cancelled."
    
      else
        flash[:message] = "Unknown response status: #{openid_response.status}"
    end
    redirect_to redirect_url
  end
end
