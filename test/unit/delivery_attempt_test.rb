require 'test_helper'
require 'mocha'

class DeliveryAttemptTest < ActiveSupport::TestCase
  test "valid delivery attempt should be valid" do
    assert Factory.build(:delivery_attempt).valid?
  end

  test "should be invalid without an associated notification" do
    assert Factory.build(:delivery_attempt, :notification => nil).invalid?
  end

  #----------------------------------------------------------------------------#
  # message_id:
  #------------
  test "notification's message_id should be accessible locally" do
    attempt = Factory.build(:delivery_attempt, :message_id => nil)
    assert_equal attempt.notification.message_id, attempt.message_id
  end

  test "should be invalid if notifier doesn't have a message_id" do
    n = Factory.create(:notification)
    n.message_id = nil
    assert Factory.build(:delivery_attempt, :notification => n).invalid?
  end

  #----------------------------------------------------------------------------#
  # phone_number:
  #--------------
  test "notification's phone_number should be accessible locally" do
    attempt = Factory.build(:delivery_attempt, :phone_number => nil)
    assert_equal attempt.notification.phone_number, attempt.phone_number
  end

  test "should be invalid if notifier doesn't have a phone_number" do
    n = Factory.create(:notification)
    n.phone_number = nil
    assert Factory.build(:delivery_attempt, :notification => n).invalid?
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "notification's delivery_method should be accessible locally" do
    attempt = Factory.build(:delivery_attempt, :delivery_method => nil)
    assert_equal attempt.notification.delivery_method, attempt.delivery_method
  end

  test "should be invalid if notifier doesn't have a delivery_method" do
    n = Factory.create(:notification)
    n.delivery_method = nil
    assert Factory.build(:delivery_attempt, :notification => n).invalid?
  end

  #----------------------------------------------------------------------------#
  # save/deliver hooks:
  #--------------------
  test "overridden values get reset so notification ones used for validation" do
    attempt = Factory.build(:delivery_attempt)
    attempt.phone_number = '99994'
    attempt.valid?
    assert_equal attempt.notification.phone_number, attempt.phone_number
  end

  test "should attempt delivery once on save" do
    attempt = Factory.build(:delivery_attempt)
    attempt.expects(:deliver).once
    assert_equal true, attempt.save
  end

  test "should not attempt delivery on subsequent save attempts" do
    attempt = Factory.create(:delivery_attempt)
    attempt.expects(:deliver).never
    8.times { attempt.save }
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Notification:
  #------------------------------
  test "can access notification from delivery attempt" do
    assert Factory.build(:delivery_attempt).notification
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Message:
  #-------------------------
  test "can access message from delivery attempt after save" do
    assert Factory.build(:delivery_attempt).message
  end

end
