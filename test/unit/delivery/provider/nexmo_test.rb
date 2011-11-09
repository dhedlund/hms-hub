require 'test_helper'
require 'restclient'
require 'mocha'

# minimum configuration required to initialize a new nexmo provider
NEXMO_CONFIG = { :api_key => 'foo', :api_secret => 'bar' }

class Delivery::Provider::NexmoTest < ActiveSupport::TestCase
  Delivery::Agent.instance.register(Delivery::Provider::Dummy.new, 'sms')

  setup do
    @provider = Delivery::Provider::Nexmo.new(NEXMO_CONFIG)
    @attempt = Factory.create(:delivery_attempt)
  end

  #----------------------------------------------------------------------------#
  # api_key:
  #---------
  test "should be able to specify a custom api_key" do
    config = NEXMO_CONFIG.merge({:api_key => 'nonstandard'})
    provider = Delivery::Provider.new(:nexmo, config)
    assert_equal 'nonstandard', provider.api_key
  end

  #----------------------------------------------------------------------------#
  # api_secret:
  #------------
  test "should be able to specify a custom api_secret" do
    config = NEXMO_CONFIG.merge({:api_secret => 'hushnow'})
    provider = Delivery::Provider.new(:nexmo, config)
    assert_equal 'hushnow', provider.api_secret
  end

  #----------------------------------------------------------------------------#
  # client_ref:
  #------------
  test "should be able to specify a custom client_ref value" do
    config = NEXMO_CONFIG.merge({:client_ref => 'myclient'})
    provider = Delivery::Provider.new(:nexmo, config)
    assert_equal 'myclient', provider.client_ref
  end

  #----------------------------------------------------------------------------#
  # deliver:
  #---------
  test "deliver should return true on successful send" do
    @provider.stubs(:handle_request).returns(fake_response)
    assert_equal true, @provider.deliver(@attempt)
  end

  test "deliver should attempt to interpolate variables in sms_text" do
    @provider.stubs(:handle_request).returns(fake_response)
    @attempt.message.expects(:sms_text).with({ 'foo' => 'bar' })
    @attempt.notification.variables = { 'foo' => 'bar' }
    @provider.deliver(@attempt)
  end

  test "deliver should return false if one or more nexmo msgs not success" do
    @provider.stubs(:handle_request).returns(fake_response(['0','0','4','0']))
    assert_equal false, @provider.deliver(@attempt)
  end

  test "deliver should update attempt result to ASYNC_DELIVERY on success" do
    @provider.stubs(:handle_request).returns(fake_response)
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::ASYNC_DELIVERY, @attempt.result
  end

  test "deliver should not override TEMP_FAIL w/ ASYNC_DELIVERY" do
    @provider.stubs(:handle_request).returns(fake_response(['1','0']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
  end

  test "deliver should not override PERM_FAIL w/ TEMP_FAIL" do
    @provider.stubs(:handle_request).returns(fake_response(['2','1']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
  end

  test "deliver should not override PERM_FAIL w/ ASYNC_DELIVERY" do
    @provider.stubs(:handle_request).returns(fake_response(['2','0']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
  end

  test "deliver should override ASYNC_DELIVERY w/ PERM_ or TEMP_ FAIL" do
    @provider.stubs(:handle_request).returns(fake_response(['0','1']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
  end

  test "deliver should save all nexmo messages to database" do
    @provider.stubs(:handle_request).returns(fake_response(['0','0','4','0']))
    assert_difference('NexmoOutboundMessage.count', 4) do
      @provider.deliver(@attempt)
    end
  end

  test "deliver should set REMOTE_ERROR if RestClient::Exception" do
    exception = RestClient::Exception.new(mock_restclient_response(500), 500)
    @provider.stubs(:handle_request).raises(exception)
    assert_equal false, @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::REMOTE_ERROR, @attempt.error_type
  end

  test "deliver should set REMOTE_TIMEOUT if Errno::ETIMEDOUT" do
    @provider.stubs(:handle_request).raises(Errno::ETIMEDOUT)
    assert_equal false, @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::REMOTE_TIMEOUT, @attempt.error_type
  end

  test "deliver should set INTERNAL_ERROR if unknown exception" do
    class AliensHaveLanded < StandardError; end
    @provider.stubs(:handle_request).raises(AliensHaveLanded)
    assert_equal false, @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::INTERNAL_ERROR, @attempt.error_type
  end

  test "deliver supports nexmo response code 0 (success)" do
    @provider.stubs(:handle_request).returns(fake_response(['0']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::ASYNC_DELIVERY, @attempt.result
    assert_nil NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 1 (throttled)" do
    @provider.stubs(:handle_request).returns(fake_response(['1']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::THROTTLED, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 2 (missing params)" do
    @provider.stubs(:handle_request).returns(fake_response(['2']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::MISSING_PARAMS, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 3 (invalid params" do
    @provider.stubs(:handle_request).returns(fake_response(['3']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::INVALID_PARAMS, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 4 (invalid creds)" do
    @provider.stubs(:handle_request).returns(fake_response(['4']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::INVALID_CREDS, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 5 (nexmo error)" do
    @provider.stubs(:handle_request).returns(fake_response(['5']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::NEXMO_ERROR, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 6 (invalid message)" do
    @provider.stubs(:handle_request).returns(fake_response(['6']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::INVALID_MESSAGE, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 7 (blacklisted)" do
    @provider.stubs(:handle_request).returns(fake_response(['7']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::BLACKLISTED, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 8 (account barred)" do
    @provider.stubs(:handle_request).returns(fake_response(['8']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::ACCOUNT_BARRED, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 9 (no credits)" do
    @provider.stubs(:handle_request).returns(fake_response(['9']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::NO_CREDITS, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 10 (connection limit)" do
    @provider.stubs(:handle_request).returns(fake_response(['10']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::CONNECTION_LIMIT, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 11 (REST disabled)" do
    @provider.stubs(:handle_request).returns(fake_response(['11']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::REST_DISABLED, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports nexmo response code 12 (message length)" do
    @provider.stubs(:handle_request).returns(fake_response(['12']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::MESSAGE_LENGTH, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  test "deliver supports unknown nexmo responses" do
    @provider.stubs(:handle_request).returns(fake_response(['SOS']))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Nexmo::UNKNOWN_ERROR, @attempt.error_type
    assert_equal NexmoOutboundMessage::FAILED, NexmoOutboundMessage.first.status
  end

  #----------------------------------------------------------------------------#
  # delivery_details:
  #------------------
  test "delivery_details should return any associated outbound messages" do
    messages = 2.times.map do
      Factory.create(:nexmo_outbound_message, :delivery_attempt => @attempt)
    end
    Factory.create(:nexmo_outbound_message)

    matched = @provider.class.delivery_details(@attempt.id)
    assert_equal messages.map(&:id).sort, matched.map(&:id).sort
  end

  #----------------------------------------------------------------------------#
  # from:
  #------
  test "should be able to specify a custom from value" do
    config = NEXMO_CONFIG.merge({:from => 'everyone!'})
    provider = Delivery::Provider.new(:nexmo, config)
    assert_equal 'everyone!', provider.from
  end

  #----------------------------------------------------------------------------#
  # json_endpoint:
  #---------------
  test "should be able to specify a custom json_endpoint" do
    config = NEXMO_CONFIG.merge({:json_endpoint => 'my.custom.endpoint'})
    provider = Delivery::Provider.new(:nexmo, config)
    assert_equal 'my.custom.endpoint', provider.json_endpoint
  end

  test "default json_endpoint should be http://rest.nexmo.com/sms/json" do
    config = NEXMO_CONFIG.merge({:json_endpoint => nil})
    provider = Delivery::Provider.new(:nexmo, config)
    assert_equal 'http://rest.nexmo.com/sms/json', provider.json_endpoint
  end

  #----------------------------------------------------------------------------#
  # new:
  #-----
  test "should be able to create a new nexmo provider directly" do
    assert_equal Delivery::Provider::Nexmo, @provider.class
  end

  test "should be able to create a new nexmo provider by name" do
    provider = Delivery::Provider.new(:nexmo, NEXMO_CONFIG)
    assert_equal Delivery::Provider::Nexmo, provider.class
  end

  test "should be able to create a new nexmo provider by class" do
    provider = Delivery::Provider.new(:custom, NEXMO_CONFIG.merge({
      :class => 'Delivery::Provider::Nexmo'
    }))
    assert_equal Delivery::Provider::Nexmo, provider.class
  end

  test "should raise exception if no api_key is provided to :new" do
    assert_raise(Delivery::Provider::Nexmo::ConfigurationError) do
      Delivery::Provider.new(:nexmo, NEXMO_CONFIG.merge({:api_key => nil}))
    end
  end

  test "should raise exception if no api_secret is provided to :new" do
    assert_raise(Delivery::Provider::Nexmo::ConfigurationError) do
      Delivery::Provider.new(:nexmo, NEXMO_CONFIG.merge({:api_secret => nil}))
    end
  end


  def fake_response(statuses=['0'])
    response = { 'message-count' => statuses.size, 'messages' => [] }
    statuses.each_with_index do |v,i|
      response['messages'] << { 'message-id' => "fake#{i}", 'status' => v.to_s }
    end

    response
  end

  def mock_restclient_response(code, body = '')
    net_http_res = mock()
    net_http_res.stubs(:code).returns(code)
    net_http_res.stubs(:body).returns(body)
    RestClient::Response.create(body, net_http_res, nil)
  end

end
