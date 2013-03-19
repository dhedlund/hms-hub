class Admin::MessagesController < AdminController
  respond_to :html, :json

  def show
    @message_stream = MessageStream.find(params[:message_stream_id])
    authorize! :show, @message_stream

    @message = @message_stream.messages.find(params[:id])
    authorize! :show, @message

    respond_with @message
  end

end
