class NexmoController < ApplicationController
  def confirm_delivery
    @message = NexmoOutboundMessage.find_by_ext_message_id(params[:messageId])
    unless @message
      log_message_error(@message, 'message not found for confirmation')
      render :text => 'ERROR', :status => :unprocessable_entity
      return
    end

    success = @message.update_attributes({
      :to_msisdn    => params[:msisdn],
      :network_code => params[:'network-code'],
      :mo_tag       => params[:'mo-tag'],
      :status       => params[:status],
      :scts         => params[:scts],
    })
    unless success
      log_message_error(@message, 'failed to save delivery confirmation')
      render :text => 'ERROR', :status => :unprocessable_entity
      return
    end

    render :text => 'OK'
  end

  def accept_delivery
    @message = NexmoInboundMessage.new
    @message.attributes = {
      :ext_message_id => params[:messageId],
      :to_msisdn      => params[:to],
      :mo_tag         => params[:'mo-tag'],
      :text           => params[:text],
    }

    unless @message.save
      log_message_error(@message, 'received an invalid inbound SMS')
      render :text => 'ERROR', :status => :unprocessable_entity
      return
    end

    render :text => 'OK'
  end


  protected

  def log_message_error(message, description)
    logger.error <<-ERRORMSG.strip_heredoc
      [NEXMO] #{description}:
        Validation Errors: #{message.errors.inspect if message}
        Query Params: #{params.inspect}
    ERRORMSG
  end

end
