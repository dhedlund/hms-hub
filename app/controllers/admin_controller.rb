class AdminController < ApplicationController
  respond_to :html

  before_filter :authenticate, :setup_i18n

  helper_method :current_user, :current_ability

  REPORT_PATH = '/var/www/apps/hms-deploy-ccpf/hms-hub/reports/'
  # GET /admin/index
  def index
    @status_codes = Notification::VALID_STATUSES 
    @delivery_methods = Notification::VALID_DELIVERY_METHODS
    @notifiers = current_user.notifiers.active.reorder(:name)

    # move the internal notifier to the end
    internal_username = Notifier.internal.try(:username)
    if internal_pos = @notifiers.index {|n| n.username == internal_username }
      @notifiers << @notifiers.delete_at(internal_pos)
    end

    status_data = @notifiers.map do |notifier|
      notif_time = Notifier.where(:username=>notifier.username).first.last_status_req_at
      notif_hours_ago = ((Time.now - notif_time)/3600).to_i

      begin
        last_report_sync = File.mtime(REPORT_PATH+notifier.username)
      rescue Exception => e
        logger.warn "Error getting mtime of #{REPORT_PATH+notifier.username}: #{e.inspect}"
        last_report_sync = 'unknown'
      end
      [notifier.username, {'last_notif_sync'=>notif_time, 'last_notif_hours_ago'=>notif_hours_ago, 'last_report_sync'=>last_report_sync} ]
    end

    @status = Hash[status_data]
    
    short_fmt='%d%b'
    url_fmt='%Y-%m-%d'
    @date_range_data = {
      'today'     => {'start' => Date.today,           'end' => Date.today},
      'yesterday' => {'start' => Date.today - 1.day,   'end' => Date.today - 1.day},
      'last_7'    => {'start' => Date.today - 6.days,  'end' => Date.today},
      'prev_7'    => {'start' => Date.today - 13.days, 'end' => Date.today - 7.days},
    }


    notif_db_counts = {}
    @date_range_data.each do |rcode, data|
      data['label'] = data['start'].strftime(short_fmt)
      data['label'] += "-"+data['end'].strftime(short_fmt) if data['start'] != data['end']
      data['start_time_utc'] = Time.zone.parse(data['start'].to_s).utc
      data['end_time_utc']   = Time.zone.parse( (data['end']+1.day).to_s).utc
      data['url_vars'] ={        
        'delivery_start_gteq'=> data['start'].strftime(url_fmt),
        'delivery_start_lteq'=> data['end'].strftime(url_fmt),
      }
      notif_scope = Notification.where("delivery_start >= ? AND delivery_start < ?", data['start_time_utc'], data['end_time_utc'])
      #NOTE:  ignoring NEW (should be brand-new and only in last 24h) and edge-case CANCELLED
      data['notif_counts'] = Hash.new(0).merge( notif_scope.count(:group=>[:notifier_id, :delivery_method, :status]) 
              ).merge( notif_scope.where(:status=>@status_codes).count(:group=>[:notifier_id, :delivery_method]) )
    end

    @date_range_codes = @date_range_data.keys
    
    render :dashboard
  end


  # ANY /admin/*
  def not_found
    render :text => '404 Not Found', :status => '404'
  end

  def current_user
    @current_user
  end

  def current_ability
    @current_ability
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
        @current_ability = user.ability
      end
    end
  end

  def setup_i18n
    locale = params[:locale].present? ? params[:locale] : nil
    locale ||= @current_user.locale if @current_user
    locale ||= 'en'

    @i18n_defaults = {
      :locale => locale,
      :raise  => true,
    }
  end

end
