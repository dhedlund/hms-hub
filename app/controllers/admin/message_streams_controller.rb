class Admin::MessageStreamsController < AdminController
  respond_to :html, :json

  def index
    authorize! :index, MessageStream
    @message_streams = MessageStream.accessible_by(current_ability)

    respond_with @message_streams
  end

  def show
    @message_stream = MessageStream.find(params[:id])
    authorize! :show, @message_stream

    @messages = @message_stream.messages

    respond_with @message_stream, :include => :messages
  end

end
