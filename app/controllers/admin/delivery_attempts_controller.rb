class Admin::DeliveryAttemptsController < AdminController
  respond_to :html, :json

  def index
    @delivery_attempts = DeliveryAttempt.scoped
    respond_with @delivery_attempts
  end

  def show
    @delivery_attempt = DeliveryAttempt.find(params[:id])
    @message = Message.find(@delivery_attempt.message_id)
    respond_with @delivery_attempt
  end
end
