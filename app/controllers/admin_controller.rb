class AdminController < ApplicationController
  respond_to :html

  before_filter :authenticate

  # GET /admin/index
  def index
  end

  # ANY /admin/*
  def not_found
    render :text => '404 Not Found', :status => '404'
  end

  def current_user
    @current_user
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      user = User.find_by_username(username)
      if user && username == user.username && password == user.password
        user.save

        Time.zone = user.timezone
        @current_user = user
      end
    end
  end

end
