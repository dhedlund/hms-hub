class Api::MessageStreamsController < ApiController
  respond_to :json

  def index
    streams = MessageStream.scoped
    render :json => streams.to_json(
      :only => [:name, :title],
      :include => {
        :messages => {
          :only => [ :name, :offset_days, :sms_text ]
        }
      }
    )
  end
end
