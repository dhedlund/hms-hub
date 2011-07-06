require 'test_helper'

class Delivery::ProviderTest < ActiveSupport::TestCase
  class Delivery::Provider::MockProvider
    def initialize(config={}); end
  end

  #----------------------------------------------------------------------------#
  # name:
  #------
  test "should be able to get the name a provider was created with" do
    provider = Delivery::Provider.new(:mock_provider)
    assert_equal 'mock_provider', provider.name
  end

  test "should return name provided, even if not same as class" do
    provider = Delivery::Provider.new(:government, {
      :class => 'Delivery::Provider::MockProvider'
    })
    assert_equal 'government', provider.name
  end

  #----------------------------------------------------------------------------#
  # new:
  #-----
  test "should be able to create a new provider based on a name (symbol)" do
    provider = Delivery::Provider.new(:mock_provider)
    assert_equal Delivery::Provider::MockProvider, provider.class
  end

  test "should be able to create a new provider based on a name (string)" do
    provider = Delivery::Provider.new('mock_provider')
    assert_equal Delivery::Provider::MockProvider, provider.class
  end

  test "should be able to create a new provider based on a class" do
    provider = Delivery::Provider.new(:government, {
      :class => 'Delivery::Provider::MockProvider'
    })
    assert_equal Delivery::Provider::MockProvider, provider.class
  end

  test "should raise an error if provider class not found" do
    assert_raise(NameError) { Delivery::Provider.new(:circus) }
  end

  test "should pass configuration to real provider" do
    config = { :abc => 123 }
    Delivery::Provider::MockProvider.expects(:new).once.with(config)
    Delivery::Provider.new(:mock_provider, config)
  end

end
