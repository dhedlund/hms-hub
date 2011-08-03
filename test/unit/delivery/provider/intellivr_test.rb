require 'test_helper'
require 'restclient'
require 'mocha'

# minimum configuration required to initialize an intellivr provider
INTELLIVR_CONFIG = { :api_key => 'foo', :base_url => 'localhost', :callback_url => 'localhost' }

class Delivery::Provider::IntellivrTest < ActiveSupport::TestCase
  Delivery::Agent.instance.register(Delivery::Provider::Dummy.new, 'intellivr')

  setup do
    @provider = Delivery::Provider::Intellivr.new(INTELLIVR_CONFIG)
    @attempt = Factory.create(:delivery_attempt, :delivery_method => 'IVR')
  end

  #----------------------------------------------------------------------------#
  # api_key:
  #---------
  test "should be able to specify a custom api_key" do
    config = INTELLIVR_CONFIG.merge({:api_key => 'nonstandard'})
    provider = Delivery::Provider.new(:intellivr, config)
    assert_equal 'nonstandard', provider.api_key
  end

  #----------------------------------------------------------------------------#
  # base_url:
  #----------
  test "should be able to specify a custom base_url" do
    config = INTELLIVR_CONFIG.merge({:base_url => 'my.base.url'})
    provider = Delivery::Provider.new(:intellivr, config)
    assert_equal 'my.base.url', provider.base_url
  end

  #----------------------------------------------------------------------------#
  # callback_url:
  #--------------
  test "should be able to specify a custom callback_url" do
    config = INTELLIVR_CONFIG.merge({:callback_url => 'my.callback.url'})
    provider = Delivery::Provider.new(:intellivr, config)
    assert_equal 'my.callback.url', provider.callback_url
  end

  #----------------------------------------------------------------------------#
  # deliver:
  #---------
  test "deliver should return true if api call returns OK status" do
    @provider.stubs(:handle_request).returns(fake_response)
    assert_equal true, @provider.deliver(@attempt)
  end

  test "deliver should return false if api call returns an error" do
    @provider.stubs(:handle_request).returns(fake_response('0009'))
    assert_equal false, @provider.deliver(@attempt)
  end

  test "deliver should update attempt result to ASYNC_DELIVERY on success" do
    @provider.stubs(:handle_request).returns(fake_response)
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::ASYNC_DELIVERY, @attempt.result
  end

  test "deliver should save intellivr message to database" do
    @provider.stubs(:handle_request).returns(fake_response)
    assert_difference('IntellivrOutboundMessage.count') do
      @provider.deliver(@attempt)
    end
  end

  test "deliver should set REMOTE_ERROR if RestClient::Exception" do
    exception = RestClient::Exception.new(mock_restclient_response(500), 500)
    @provider.stubs(:handle_request).raises(exception)
    assert_equal false, @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::REMOTE_ERROR, @attempt.error_type
  end

  test "deliver should set REMOTE_TIMEOUT if Errno::ETIMEDOUT" do
    @provider.stubs(:handle_request).raises(Errno::ETIMEDOUT)
    assert_equal false, @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::REMOTE_TIMEOUT, @attempt.error_type
  end

  test "deliver should set INTERNAL_ERROR if unknown exception" do
    class AliensHaveLanded < StandardError; end
    @provider.stubs(:handle_request).raises(AliensHaveLanded)
    assert_equal false, @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::INTERNAL_ERROR, @attempt.error_type
  end

  test "deliver supports intellivr error '0000' (Unknown error)" do
    @provider.stubs(:handle_request).returns(fake_response('0000'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::UNKNOWN_ERROR, @attempt.error_type
  end

  test "deliver supports intellivr error '0001' (No action)" do
    @provider.stubs(:handle_request).returns(fake_response('0001'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::NO_ACTION, @attempt.error_type
  end

  test "deliver supports intellivr error '0002' (Malformed XML)" do
    @provider.stubs(:handle_request).returns(fake_response('0002'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::MALFORMED_XML, @attempt.error_type
  end

  test "deliver supports intellivr error '0003' (Invalid sound filename format)" do
    @provider.stubs(:handle_request).returns(fake_response('0003'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::INVALID_SOUND, @attempt.error_type
  end

  test "deliver supports intellivr error '0004' (Invalid URL format)" do
    @provider.stubs(:handle_request).returns(fake_response('0004'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::INVALID_URL, @attempt.error_type
  end

  test "deliver supports intellivr error '0005' (Unsupported report type)" do
    @provider.stubs(:handle_request).returns(fake_response('0005'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::REPORT_TYPE, @attempt.error_type
  end

  test "deliver supports intellivr error '0006' (Invalid API Identifier)" do
    @provider.stubs(:handle_request).returns(fake_response('0006'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::API_IDENT, @attempt.error_type
  end

  test "deliver supports intellivr error '0007' (Tree does not exist)" do
    @provider.stubs(:handle_request).returns(fake_response('0007'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::MISSING_TREE, @attempt.error_type
  end

  test "deliver supports intellivr error '0008' (Invalid Language)" do
    @provider.stubs(:handle_request).returns(fake_response('0008'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::INVALID_LANG, @attempt.error_type
  end

  test "deliver supports intellivr error '0009' (Invalid Method)" do
    @provider.stubs(:handle_request).returns(fake_response('0009'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::INVALID_METHOD, @attempt.error_type
  end

  test "deliver supports intellivr error '0010' (Invalid Callee)" do
    @provider.stubs(:handle_request).returns(fake_response('0010'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::INVALID_CALLEE, @attempt.error_type
  end

  test "deliver supports intellivr error '0011' (Bad Request)" do
    @provider.stubs(:handle_request).returns(fake_response('0011'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::TEMP_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::BAD_REQUEST, @attempt.error_type
  end

  test "deliver supports unknown error codes" do
    @provider.stubs(:handle_request).returns(fake_response('9999'))
    @provider.deliver(@attempt)
    assert_equal DeliveryAttempt::PERM_FAIL, @attempt.result
    assert_equal Delivery::Provider::Intellivr::UNKNOWN_ERROR, @attempt.error_type
  end

  #----------------------------------------------------------------------------#
  # new:
  #-----
  test "should be able to create a new intellivr provider directly" do
    assert_equal Delivery::Provider::Intellivr, @provider.class
  end

  test "should be able to create a new intellivr provider by name" do
    provider = Delivery::Provider.new(:intellivr, INTELLIVR_CONFIG)
    assert_equal Delivery::Provider::Intellivr, provider.class
  end

  test "should be able to create a new intellivr provider by class" do
    provider = Delivery::Provider.new(:custom, INTELLIVR_CONFIG.merge({
      :class => 'Delivery::Provider::Intellivr'
    }))
    assert_equal Delivery::Provider::Intellivr, provider.class
  end

  test "should raise exception if no api_key is provided to :new" do
    assert_raise(Delivery::Provider::Intellivr::ConfigurationError) do
      Delivery::Provider.new(:intellivr, INTELLIVR_CONFIG.merge({:api_key => nil }))
    end
  end

  test "should raise exception if no base_url is provided to :new" do
    assert_raise(Delivery::Provider::Intellivr::ConfigurationError) do
      Delivery::Provider.new(:intellivr, INTELLIVR_CONFIG.merge({:base_url => nil }))
    end
  end


  test "should raise exception if no callback_url is provided to :new" do
    assert_raise(Delivery::Provider::Intellivr::ConfigurationError) do
      Delivery::Provider.new(:intellivr, INTELLIVR_CONFIG.merge({:callback_url => nil }))
    end
  end


  protected

  def fake_response(error_code=nil)
    tags = { 'Status' => Delivery::Provider::Intellivr::OK }
    if error_code
      tags['Status'] = Delivery::Provider::Intellivr::ERROR
      tags['ErrorCode'] = error_code
      tags['ErrorString'] = 'Test Error Message'
    end

    <<-XML_RES
    <AutoCreate>
    <Response>
    #{ tags.map { |k,v| "<#{k}>#{v}</#{k}>" } }
    </Response>
    </AutoCreate>
    XML_RES
  end


  def mock_restclient_response(code, body = '')
    net_http_res = mock()
    net_http_res.stubs(:code).returns(code)
    net_http_res.stubs(:body).returns(body)
    RestClient::Response.create(body, net_http_res, nil)
  end

end
