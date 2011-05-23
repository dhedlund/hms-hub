class ApiController < ApplicationController
  respond_to :json

  before_filter :authenticate

  # GET /api/test/ping
  def ping
    render :text => 'pong'
  end

  # ANY /api/*
  def not_found
    render :text => '404 Not Found', :status => '404'
  end

  def current_user
    @current_user
  end


  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      user = Notifier.find_by_username(username)
      if user && username == user.username && password == user.password
        user.last_login_at = Time.now
        user.save

        @current_user = user
      end
    end
  end

end
