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
  # notification:
  #--------------
  test "assigning a notification should set related attributes" do
    notification = Factory.build(:notification)
    attempt = Factory.build(:delivery_attempt, :notification => nil)
    attempt.notification = notification

    assert_equal notification.message, attempt.message
    assert_equal notification.message_id, attempt.message_id
    assert_equal notification.phone_number, attempt.phone_number
    assert_equal notification.delivery_method, attempt.delivery_method
  end

  test "should not update notifications related attributes on fetch" do
    notification = Factory.create(:notification, :phone_number => '12345')
    attempt = Factory.create(:delivery_attempt, :notification => notification)
    notification.phone_number = '54321'
    notification.save!

    assert_equal attempt, DeliveryAttempt.find(attempt.id)
  end

  #----------------------------------------------------------------------------#
  # message_id:
  #------------
  test "constructing without message_id should pull from notification" do
    attempt = Factory.build(:delivery_attempt, :message_id => nil)
    assert_equal attempt.notification.message_id, attempt.message_id
  end

  test "should be invalid if a message_id isn't provided" do
    attempt = Factory.build(:delivery_attempt)
    attempt.message_id = nil
    assert attempt.invalid?
  end

  #----------------------------------------------------------------------------#
  # phone_number:
  #--------------
  test "constructing without phone_number should pull from notification" do
    attempt = Factory.build(:delivery_attempt, :phone_number => nil)
    assert_equal attempt.notification.phone_number, attempt.phone_number
  end

  test "should be invalid if a phone_number isn't provided" do
    attempt = Factory.build(:delivery_attempt)
    attempt.phone_number = nil
    assert attempt.invalid?
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "constructing without delivery_method should pull from notification" do
    attempt = Factory.build(:delivery_attempt, :delivery_method => nil)
    assert_equal attempt.notification.delivery_method, attempt.delivery_method
  end

  test "should be invalid if a delivery_method isn't provided" do
    attempt = Factory.build(:delivery_attempt)
    attempt.delivery_method = nil
    assert attempt.invalid?
  end

  #----------------------------------------------------------------------------#
  # result:
  #--------
  test "should be valid if no result is specified before first save/create" do
    assert Factory.build(:delivery_attempt, :result => nil).valid?
  end

  test "should be invalid to have no result after the attempt is saved" do
    attempt = Factory.create(:delivery_attempt)
    attempt.result = nil
    assert attempt.invalid?
  end

  test "should be invalid if result is not in list of valid results" do
    assert Factory.build(:delivery_attempt, :result => 'LOST_IN_TIME').invalid?

    attempt = Factory.create(:delivery_attempt)
    attempt.result = 'LOST_IN_TIME'
    assert attempt.invalid?
  end

  test "should be valid if result is in the list of valid results" do
    assert Factory.build(:delivery_attempt,
      :result => DeliveryAttempt::SUCCESS
    ).valid?

    attempt = Factory.create(:delivery_attempt)
    attempt.result = DeliveryAttempt::SUCCESS
    assert attempt.valid?
  end

  #----------------------------------------------------------------------------#
  # save/deliver hooks:
  #--------------------
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
