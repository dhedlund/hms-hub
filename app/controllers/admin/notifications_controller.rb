class Admin::NotificationsController < AdminController
  respond_to :html, :json

  def index
    authorize! :index, Notification
    @notifications = Notification.accessible_by(current_ability)

    @search_params = params.slice(*allowed_search_params)
    @notifications = search(@notifications, @search_params)
    @notifications_count = @notifications.count
    @notifications = @notifications.order('delivery_start DESC').page(params[:page])

    @notifiers = current_user.notifiers.reorder(:name)

    respond_with @notifications
  end

  def show
    @notification = Notification.find(params[:id])
    authorize! :show, @notification

    @notifier_id = @notification.notifier.id
    @notifier_name = @notification.notifier.name
    @notifiers = current_user.notifiers
    @attempts = @notification.delivery_attempts
    @message = @notification.message

    respond_with @notification
  end

  def new
    authorize! :create, Notification

    @notification = Notification.new
    @notification[:message_id] = params[:message_id]
    @notification[:delivery_method] = params[:delivery_method]
    @notification.notifier = Notifier.internal

    respond_with :admin, @notification
  end

  def create
    authorize! :create, Notification

    @notification = Notification.new
    @notification.attributes = params[:notification]
    @notification.delivery_start = Time.zone.now
    @notification.notifier = Notifier.internal

    if @message = @notification.message
      @notification.delivery_method = @message.delivery_method
    end

    authorize! :create, @notification

    @notification.save
    respond_with :admin, @notification
  end


  private

  def allowed_search_params
    %w(
      delivery_method_eq delivery_start_gteq delivery_start_lteq
      delivered_at_gteq delivered_at_lteq delivered_at_null
      first_name_cont last_error_type_eq notifier_id_eq
      phone_number_cont phone_number_eq status_eq
    )
  end

end
