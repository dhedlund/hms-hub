class AdminController < ApplicationController
  respond_to :html

  before_filter :authenticate, :setup_i18n

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

    render :dashboard
  end


  # ANY /admin/*
  def not_found
    render :text => '404 Not Found', :status => '404'
  end

  def current_user
    @current_user
  end


  protected

  def search(scope, search_params)
    # don't change search_params outside of scope, might change form values
    search_params = search_params.dup

    # datetime fields are problematic if presented to user as a date, due
    # to the expectation that the end date is inclusive.  try to compensate
    dt_columns = scope.columns.select {|c| c.type == :datetime }.map(&:name)
    dt_columns.map {|c| ["#{c}_lt", "#{c}_lteq"]}.flatten.each do |param|
      if search_params[param] =~ /\A(\d{4}-\d{2}-\d{2})\Z/
        inclusive_date = ($1.to_date + 1.day).strftime('%Y-%m-%d') rescue nil
        search_params[param] = inclusive_date
      end
    end

    # phone numbers are stored in a normalized form (just numbers)
    phone_params = search_params.slice('phone_number_eq', 'phone_number_cont')
    phone_params.select {|p,v| v.present? }.each do |param,value|
      # TODO: move regexp/logic to configuration so other users
      # and/or notifiers can customize normalization process
      search_params[param] = value.gsub(/^0|[^\d]/, '')
    end

    scope.search(search_params).result
  end


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

  def setup_i18n
    @i18n_defaults = {
      :raise => true,
    }
  end

end
