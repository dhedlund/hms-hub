require 'test_helper'

class Delivery::AgentTest < ActiveSupport::TestCase
  class Delivery::Provider::MockProvider1; def initialize(config={}); end; end
  class Delivery::Provider::MockProvider2; def initialize(config={}); end; end
  class Delivery::Provider::MockProvider3; def initialize(config={}); end; end

  setup do
    @agent = Delivery::Agent.new
  end

  #----------------------------------------------------------------------------#
  # []: (fetch)
  #------------
  test "should be able to fetch provider registered for a service" do
    provider = mock()
    @agent.register(provider, :dummy)
    assert_equal provider, @agent[:dummy]
  end

  test "fetching a provider from an unsupported delivery service returns nil" do
    @agent.register(mock(), :dummy)
    assert_nil @agent[:pigeon]
  end

  test "should be able to fetch a provider using a symbol-based service name" do
    @agent.register(mock(), 'dummy')
    assert @agent[:dummy]
  end

  test "should be able to fetch a provider using a string-based service name" do
    @agent.register(mock(), :dummy)
    assert @agent['dummy']
  end

  #----------------------------------------------------------------------------#
  # instance:
  #----------
  test "should support a singleton instance of agent (for global registry)" do
    assert_equal Delivery::Agent.instance, Delivery::Agent.instance
  end

  test "should be able to register providers with a singleton instance" do
    provider = Delivery::Agent.instance.register(mock(), :dummy)
    assert_equal provider, Delivery::Agent.instance[:dummy]
  end

  #----------------------------------------------------------------------------#
  # providers:
  #-----------
  test "an agent w/o any providers should return an empty list" do
    assert_equal [], @agent.providers
  end

  test "an agent w/ duplicate providers should return only once instance" do
    [:dummy1, :dummy2, :dummy3].each { |s| @agent.register(mock(), s) }
    @agent.register(@agent[:dummy2], :dummy4)
    assert_equal 3, @agent.providers.count
  end

  #----------------------------------------------------------------------------#
  # register:
  #----------
  test "registering a provider should return provider on success" do
    provider = mock()
    assert_equal provider, @agent.register(provider, :dummy)
  end

  test "registering another provider for a service should overwrite old one" do
    provider1 = @agent.register(mock(), :dummy)
    provider2 = @agent.register(mock(), :dummy)

    assert_not_equal provider1, @agent[:dummy]
    assert_equal provider2, @agent[:dummy]
  end

  #----------------------------------------------------------------------------#
  # register_from_config:
  #----------------------
  test "register_from_config should register a provider based on config" do
    config = { :delivery_providers => { :sms => 'mock_provider_1' } }
    assert_difference('@agent.providers.count') do
      @agent.register_from_config(config)
    end
  end

  test "register_from_config should raise error if provider info is bad" do
    config = { :delivery_providers => { :sms => 'gangstas' } }
    assert_raise(NameError) { @agent.register_from_config(config) }
  end

  test "register_from_config should be able to register multiple providers" do
    assert_difference('@agent.providers.count', 2) do
      @agent.register_from_config({
        :delivery_providers => {
          :sms => 'mock_provider_1',
          :ivr => 'mock_provider_2',
        }
      })
    end
  end

  test "register_from_config should pass provider-specific config to new" do
    config = {
      :delivery_providers => { :sms => 'myprovider' },
      :myprovider => {
        :class  => 'Delivery::Provider::MockProvider3',
        :abc123 => 'foobar',
      }
    }

    Delivery::Provider::MockProvider3.expects(:new).with(config[:myprovider])
    assert_difference('@agent.providers.count') do
      @agent.register_from_config(config)
    end
  end

  #----------------------------------------------------------------------------#
  # services:
  #----------
  test "service names returned by :services should be strings, not symbols" do
    @agent.register(mock(), :amnesiacs_anonymous)
    assert_equal ['amnesiacs_anonymous'], @agent.services
  end

  test "should be able to get a list of delivery services in sorted order" do
    ['dummy3', 'dummy1', 'dummy2'].each { |s| @agent.register(mock(), s) }
    assert_equal ['dummy1', 'dummy2', 'dummy3'], @agent.services
  end

end
