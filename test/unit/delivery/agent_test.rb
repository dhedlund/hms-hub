require 'test_helper'

class Delivery::AgentTest < ActiveSupport::TestCase
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
  # services:
  #----------
  test "should be able to get a list of delivery services in sorted order" do
    [:dummy3, :dummy1, :dummy2].each { |s| @agent.register(mock(), s) }
    assert_equal [:dummy1, :dummy2, :dummy3], @agent.services
  end

end
