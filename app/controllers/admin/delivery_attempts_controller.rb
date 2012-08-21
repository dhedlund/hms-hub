class Admin::DeliveryAttemptsController < AdminController
  respond_to :html, :json, :js

  def index
    @delivery_attempts = DeliveryAttempt.page(params[:page])
    respond_with @delivery_attempts
  end

  def show
    @delivery_attempt = DeliveryAttempt.find(params[:id])
    @message = Message.find(@delivery_attempt.message_id)
    @delivery_details = @delivery_attempt.delivery_details
    @provider = @delivery_attempt.provider

    respond_with @delivery_attempt
  end

  def phone
    @phone_number = params[:id]
    @delivery_attempts = DeliveryAttempt.where( :phone_number => @phone_number ).page(params[:page])
    respond_with @delivery_attempts
  end

  def search
    redirect_to admin_delivery_attempts_phone_url phone_normalize(params[:phone])
  end

end
