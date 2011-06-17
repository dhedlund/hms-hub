class Api::NotificationsController < ApiController
  respond_to :json

  def create
    notification = Notification.new
    notification.attributes = Hash[
      [ :uuid, :first_name, :phone_number, :delivery_method,
        :message_path
      ].map { |k| [k, params[:notification][k]] }
    ]

    notification.notifier = current_user
    notification.set_delivery_range(
      params[:notification][:delivery_date],
      params[:notification][:delivery_expires],
      params[:notification][:preferred_time]
    )

    if notification.save
      render :json => jsonify_notification(notification)
    else
      render :json => 'error', :status => :unprocessable_entity
    end
  end

  def updated
    notifications = current_user.notifications

    if from_date = current_user.last_status_req_at
      notifications = notifications.where('last_run_at > ?', from_date)
    end

    options = {}
    options[:only_status] = true if params[:only_status].present?

    current_user.update_attributes({ :last_status_req_at => Time.now })

    render :json => notifications.map { |n| jsonify_notification(n, options) }
  end

  def jsonify_notification(notification, options = {})
    start, expires, preferred_time = notification.get_delivery_range

    if options[:only_status]
      notification = {
        :notification => {
          :uuid => notification.uuid,
          :status => notification.status,
          :error => {
            :type => notification.last_error_type,
            :message => notification.last_error_msg,
          }.delete_if {|k,v| v.nil?}
        }.delete_if {|k,v| v.nil? || v.empty?}
      }
    else
      notification = {
        :notification => {
          :uuid => notification.uuid,
          :first_name => notification.first_name,
          :phone_number => notification.phone_number,
          :delivery_method => notification.delivery_method,
          :message_path => notification.message.path,
          :delivery_date => start,
          :delivery_expires => expires,
          :preferred_time => preferred_time,
          :status => notification.status,
          :error => {
            :type => notification.last_error_type,
            :message => notification.last_error_msg,
          }.delete_if {|k,v| v.nil?}
        }.delete_if {|k,v| v.nil? || v.empty?}
      }
    end

    notification
  end

end
