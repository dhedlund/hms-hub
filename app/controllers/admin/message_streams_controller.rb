class Admin::MessageStreamsController < AdminController
  respond_to :html, :json

  def index
    @message_streams = MessageStream.scoped
    respond_with @message_streams
  end

  def show
    @message_stream = MessageStream.find(params[:id])
    @messages = @message_stream.messages
    respond_with @message_stream
  end

end
