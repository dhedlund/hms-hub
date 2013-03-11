class Admin::DeliveryAttemptsController < AdminController
  respond_to :html, :json, :js

  def index
    @search_params = params.slice(*allowed_search_params)
    @delivery_attempts = search(DeliveryAttempt, @search_params)
    @delivery_attempts = @delivery_attempts.order('created_at DESC').page(params[:page])

    respond_with @delivery_attempts
  end

  def show
    @delivery_attempt = DeliveryAttempt.find(params[:id])
    @message = Message.find(@delivery_attempt.message_id)
    @delivery_details = @delivery_attempt.delivery_details
    @provider = @delivery_attempt.provider

    respond_with @delivery_attempt
  end


  private

  def allowed_search_params
    %w(
      created_at_gteq created_at_lteq delivery_method_eq error_type_eq
      notifier_id_eq phone_number_cont phone_number_eq result_eq
    )
  end

end
