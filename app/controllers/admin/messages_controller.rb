class Admin::MessagesController < AdminController
  respond_to :html, :json

  def index
    @message_stream = MessageStream.find(params[:message_stream_id])
    @messages = @message_stream.messages

    respond_with @messages do |format|
      format.html { redirect_to [:admin, @message_stream] }
    end
  end

  def show
#    @message_stream = MessageStream.find(params[:message_stream_id])
#    @message = @message_stream.messages.find(params[:id])
     @message = Message.find(params[:id])
     @message_stream = @message.message_stream
    respond_with @message
  end

end
