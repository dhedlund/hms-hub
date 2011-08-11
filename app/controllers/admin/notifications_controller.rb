class Admin::NotificationsController < AdminController
  respond_to :html, :json

  def index
    @notifications = Notification.scoped
    respond_with @notifications
  end

  def show
    @notification = Notification.find(params[:id])
    @attempts = @notification.delivery_attempts
    @message = @notification.message
    respond_with @notification
  end

  def new
    @notification = Notification.new
    respond_with :admin, @notification
  end

  def edit
    @notification = Notification.find(params[:id])
    respond_with :admin, @notification
  end

  def create
    @notification = Notification.new
    @notification.attributes = params[:notification]
    @notification.uuid ||= UUID.generate
    @notification.delivery_start ||= Time.zone.now
    @notification.save
    respond_with :admin, @notification
  end

  def update
    @notification = Notification.find(params[:id])
    @notification.update_attributes(params[:notification])
    respond_with :admin, @notification
  end

end
