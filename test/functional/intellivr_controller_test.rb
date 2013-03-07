require 'test_helper'

class IntellivrControllerTest < ActionController::TestCase
  setup do
    @outbound_msg = FactoryGirl.create(:intellivr_outbound_message)
  end

  #----------------------------------------------------------------------------#
  # confirm_delivery:
  #------------------
  test "POST :confirm_delivery w/ valid confirmation should return 200 status" do
    @request.env['RAW_POST_DATA'] = <<-XML_DATA.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <AutoCreate>
        <Report>
          <Status>CONGESTION</Status>
          <Callee>15866684036</Callee>
          <Duration>0</Duration>
          <INTELLIVREntryCount>0</INTELLIVREntryCount>
          <Private>#{@outbound_msg.ext_message_id}</Private>
        </Report>
      </AutoCreate>
    XML_DATA

    post :confirm_delivery, :format => :xml

    assert_response 200
  end

  test "POST :confirm_delivery for nonexistent message should return 422 status" do
    @request.env['RAW_POST_DATA'] = <<-XML_DATA.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <AutoCreate>
        <Report>
          <Status>CONGESTION</Status>
          <Callee>15866684036</Callee>
          <Duration>0</Duration>
          <INTELLIVREntryCount>0</INTELLIVREntryCount>
          <Private>NONEXISTENT_ID</Private>
        </Report>
      </AutoCreate>
    XML_DATA

    post :confirm_delivery, :format => :xml

    assert_response 422
  end

  test "POST :confirm_delivery for invalid confirmations should return 422 status" do
    @request.env['RAW_POST_DATA'] = <<-XML_DATA.strip_heredoc
      <?xml version="1.0" encoding="UTF-8"?>
      <AutoCreate>
      </AutoCreate>
    XML_DATA

    post :confirm_delivery, :format => :xml

    assert_response 422
  end

end
