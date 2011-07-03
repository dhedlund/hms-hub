class Api::MessageStreamsController < ApiController
  respond_to :json

  def index
    @message_streams = MessageStream.scoped
  end
end
