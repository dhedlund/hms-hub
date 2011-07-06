require 'test_helper'

class Delivery::Provider::DummyTest < ActiveSupport::TestCase
  setup do
    @attempt = Factory.build(:delivery_attempt)
    @provider = Delivery::Provider::Dummy.new
  end

  #----------------------------------------------------------------------------#
  # deliver:
  #---------
  test "deliver should return true" do
    assert_equal true, @provider.deliver(@attempt)
  end

  test "deliver should update result of attempt to DELIVERED" do
    @provider.deliver(@attempt)
    assert DeliveryAttempt::DELIVERED, @attempt.result
  end

  #----------------------------------------------------------------------------#
  # new:
  #-----
  test "should be able to create a new dummy provider directly" do
    assert_equal Delivery::Provider::Dummy, @provider.class
  end

  test "should be able to create a new dummy provider by name" do
    provider = Delivery::Provider.new(:dummy)
    assert_equal Delivery::Provider::Dummy, provider.class
  end

  test "should be able to create a new dummy provider by class" do
    provider = Delivery::Provider.new(:custom, {
      :class => 'Delivery::Provider::Dummy'
    })
    assert_equal Delivery::Provider::Dummy, provider.class
  end

end
