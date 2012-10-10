class AdminController < ApplicationController
  respond_to :html

  before_filter :authenticate

  # GET /admin/index
  def index
    ordered = Notification.order('updated_at DESC')
    delivered = ordered.where(:status => Notification::DELIVERED)
    failed = ordered.where(:status => [Notification::TEMP_FAIL, Notification::PERM_FAIL])

    ranges = { :day => 1.day.ago, :week => 1.week.ago, :month => 1.month.ago }
    notifications = Hash[ranges.map {|k,v| [k,ordered.where('updated_at > ?', v)]}]

    @notification_cnt = Hash[notifications.map {|k,v| [k,v.count]}]
    @delivered_cnt = Hash[notifications.map {|k,v| [k,v.merge(delivered).count]}]
    @failed_cnt = Hash[notifications.map {|k,v| [k,v.merge(failed).count]}]

    @failed_notifications = failed.limit(25)
  end


  # ANY /admin/*
  def not_found
    render :text => '404 Not Found', :status => '404'
  end

  def current_user
    @current_user
  end

  def phone_normalize(phone_number)
    phone_number.to_s.gsub(/[^\d]/,'').gsub(/^0/,'265')
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
