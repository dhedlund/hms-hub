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
    start, expires, preferred_time = notification.get_delivery_range

    if notification.save
      render :json => { :notification => {
        :uuid => notification.uuid,
        :first_name => notification.first_name,
        :phone_number => notification.phone_number,
        :delivery_method => notification.delivery_method,
        :message_path => notification.message.path,
        :delivery_date => start,
        :delivery_expires => expires,
        :preferred_time => preferred_time,
      } }
    else
      render :json => 'error', :status => :unprocessable_entity
    end
  end

#  def index
#    streams = MessageStream.scoped
#    render :json => streams.to_json(
#      :only => [:name, :title],
#      :include => {
#        :messages => {
#          :only => [ :name, :offset_days, :sms_text ]
#        }
#      }
#    )
#  end
end
