class Admin::NotificationsController < AdminController
  respond_to :html, :json

  def index
    @notifications = Notification.scoped
    respond_with @notifications
  end

  def show
    @notification = Notification.find(params[:id])
    @message = @notification.message
    respond_with @notification
  end

end
