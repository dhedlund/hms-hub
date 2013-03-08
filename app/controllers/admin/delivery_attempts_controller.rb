class Admin::DeliveryAttemptsController < AdminController
  respond_to :html, :json, :js

  def index
    @delivery_attempts = DeliveryAttempt.order('created_at DESC').page(params[:page])

    if params[:phone_number]
      @phone_number = phone_normalize(params[:phone_number])
      @delivery_attempts = @delivery_attempts.where('phone_number LIKE :phone_number',
        :phone_number => "%#{@phone_number}"
      )
    end

    respond_with @delivery_attempts
  end

  def show
    @delivery_attempt = DeliveryAttempt.find(params[:id])
    @message = Message.find(@delivery_attempt.message_id)
    @delivery_details = @delivery_attempt.delivery_details
    @provider = @delivery_attempt.provider

    respond_with @delivery_attempt
  end

end
