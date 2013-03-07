require 'test_helper'

class NexmoControllerTest < ActionController::TestCase
  setup do
    @outbound_msg = FactoryGirl.create(:nexmo_outbound_message)
  end

  #----------------------------------------------------------------------------#
  # confirm_delivery:
  #------------------
  test "GET /nexmo/confirm w/ valid confirmation should return 200 status" do
    get :confirm_delivery,
      :messageId      => @outbound_msg.ext_message_id,
      :msisdn         => '123456',
      :'network-code' => '24000',
      :'mo-tag'       => '00267261',
      :status         => 'delivered',
      :scts           => '1107051251'

    # API is *explicit* about 200 status
    assert_response 200
  end

  test "GET /nexmo/confirm for nonexistent message should return 422 status " do
    get :confirm_delivery,
      :msisdn         => '123456',
      :'network-code' => '24000',
      :'mo-tag'       => '00267261',
      :status         => 'delivered',
      :scts           => '1107051251'

    assert_response 422
  end

  test "GET /nexmo/confirm for invalid confirmation update should return 422" do
    get :confirm_delivery,
      :messageId      => @outbound_msg.ext_message_id

    assert_response 422
  end

  #----------------------------------------------------------------------------#
  # inbound_sms:
  #-------------
  test "GET /nexmo/inbound_sms w/ valid message should return 200 status" do
    assert_difference('NexmoInboundMessage.count') do
      get :accept_delivery,
        :messageId => '020A74D6',
        :to        => '123456',
        :'mo-tag'  => '0000000A',
        :text      => 'Cras eget velit odio.'

      # API is *explicit* about 200 status
      assert_response 200
    end
  end

  test "GET /nexmo/inbound_sms w/ invalid message should return 422 status" do
    assert_no_difference('NexmoInboundMessage.count') do
      get :accept_delivery,
        :to        => '123456',
        :'mo-tag'  => '0000000A',
        :text      => 'Cras eget velit odio.'

      assert_response 422
    end
  end

end
