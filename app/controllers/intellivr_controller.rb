class IntellivrController < ApplicationController
  def confirm_delivery
    post_body = request.body.read
    root = REXML::Document.new(post_body).root
    reports = root.get_elements('//Report')
    if reports.empty?
      log_message_error(nil, 'no reports found in confirmation', root)
      render :text => 'ERROR', :status => :unprocessable_entity
      return
    end

    reports.each do |report|
      ext_message_id = report.elements['Private'].try(:text)
      unless @message = IntellivrOutboundMessage.find_by_ext_message_id(ext_message_id)
        log_message_error(@message, 'message not found for confirmation', report)
        render :text => 'ERROR', :status => :unprocessable_entity
        return
      end

      success = @message.update_attributes({
        :callback_res  => post_body,
        :callee        => report.elements['Callee'].try(:text),
        :duration      => report.elements['Duration'].try(:text).to_i,
        :status        => report.elements['Status'].try(:text),
        :connect_at    => report.elements['ConnectTime'].try(:text),
        :disconnect_at => report.elements['DisconnectTime'].try(:text),
      })
      unless success
      log_message_error(@message, 'failed to save delivery confirmation', report)
        render :text => 'ERROR', :status => :unprocessable_entity
        return
      end
    end

    render :text => 'OK'
  end


  protected

  def log_message_error(message, description, xml)
    logger.error <<-ERRORMSG.strip_heredoc
      [INTELLIVR] #{description}:
        Validation Errors: #{message.errors.inspect if message}
        XML Body: #{xml}
    ERRORMSG
  end

end
