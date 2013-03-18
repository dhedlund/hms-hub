class Admin::DeliveryAttemptsController < AdminController
  respond_to :html, :json, :js

  def index
    @search_params = params.slice(*allowed_search_params)
    @notifiers = current_user.notifiers.reorder(:name)
    @delivery_attempts = search(DeliveryAttempt.where(:notifier_id => @notifiers), @search_params)
    @delivery_attempts = @delivery_attempts.order('created_at DESC').page(params[:page])

    respond_with @delivery_attempts
  end

  def show
    @notifiers = current_user.notifiers.reorder(:name)
    @delivery_attempt = DeliveryAttempt.where(:notifier_id => @notifiers).find(params[:id])
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
