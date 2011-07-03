class Api::NotificationsController < ApiController
  respond_to :json

  def create
    uuid = params[:notification][:uuid]
    @notification = current_user.notifications.find_or_initialize_by_uuid(uuid)

    @notification.attributes = {
      :first_name      => params[:notification][:first_name],
      :phone_number    => params[:notification][:phone_number],
      :delivery_method => params[:notification][:delivery_method],
      :message_path    => params[:notification][:message_path],
    }

    @notification.set_delivery_range(
      params[:notification][:delivery_date],
      params[:notification][:delivery_expires],
      params[:notification][:preferred_time]
    )

    if @notification.save
      respond_with @notification
    else
      render :json => 'error', :status => :unprocessable_entity
    end
  end

  def updated
    @notifications = current_user.notifications.run

    from_date = current_user.last_status_req_at
    @notifications = @notifications.run_since(from_date) if from_date

    current_user.update_attributes({ :last_status_req_at => Time.now })
  end

end
