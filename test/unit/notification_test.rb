require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "valid notification should be valid" do
    assert Factory.build(:notification).valid?
  end

  test "first name is an optional attribute" do
    assert Factory.build(:notification, :first_name => 'Cassandra').valid?
  end

  test "should be invalid without a phone number" do
    assert Factory.build(:notification, :phone_number => nil).invalid?
  end

  test "should be invalid without a notifier id" do
    assert Factory.build(:notification, :notifier_id => nil).invalid?
  end

  test "should be invalid without a message id" do
    assert Factory.build(:notification, :message_id => nil).invalid?
  end

  test "last error type attribute is optional" do
    assert Factory.build(:notification, :last_error_type => nil).valid?
  end

  test "last error msg is optional" do
    assert Factory.build(:notification, :last_error_msg => nil).valid?
  end

  test "last error msg should be able to hold long messages > 255 chars" do
    notification = Factory.build(:notification, :last_error_msg => 'x'*2048)
    assert_equal 'x'*2048, notification.last_error_msg
  end

  #----------------------------------------------------------------------------#
  # uuid:
  #------
  test "should be invalid without a uuid" do
    assert Factory.build(:notification, :uuid => nil).invalid?
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "should be invalid without a delivery method" do
    assert Factory.build(:notification, :delivery_method => nil).invalid?
  end

  test "should be invalid unless delivery method is IVR or SMS" do
    assert Factory.build(:notification, :delivery_method => 'PIGEON').invalid?
  end

  test "delivery method of IVR should be valid" do
    assert Factory.build(:notification, :delivery_method => 'IVR').valid?
  end

  test "delivery method of SMS should be valid" do
    assert Factory.build(:notification, :delivery_method => 'SMS').valid?
  end

  #----------------------------------------------------------------------------#
  # delivery_start_date:
  #---------------------
  test "should be invalid without a delivery start date" do
    assert Factory.build(:notification, :delivery_start => nil).invalid?
  end

  test "delivery start date should hold both a date and a time" do
    now = Time.now
    notification = Factory.build(:notification, :delivery_start => now)
    assert_equal now, notification.delivery_start
  end

  #----------------------------------------------------------------------------#
  # delivery_expires_date:
  #-----------------------
  test "delivery expires date should hold both a date and a time" do
    now = Time.now
    notification = Factory.build(:notification, :delivery_expires => now)
    assert_equal now, notification.delivery_expires
  end

  test "delivery expires date should default to 7 days from start date" do
    start = 5.days.ago + 4.hours
    notification = Factory.build(:notification, :delivery_start => start)
    assert_equal (start + 7.days), notification.delivery_expires
  end

  #----------------------------------------------------------------------------#
  # delivery_window:
  #------------------
  test "delivery window attribute is optional" do
    assert Factory.build(:notification, :delivery_window => nil).valid?
  end

  test "delivery window must be a whole number" do
    assert Factory.build(:notification, :delivery_window => 7.1).invalid?
  end

  test "delivery windows less than 1 hour are invalid" do
    assert Factory.build(:notification, :delivery_window => 0).invalid?
  end

  test "one hour delivery window offsets are valid" do
    assert Factory.build(:notification, :delivery_window => 1).valid?
  end

  test "delivery windows greater than or equal to 24 are invalid" do
    assert Factory.build(:notification, :delivery_window => 24).invalid?
  end

  test "delivery window of 24 hours is valid" do
    assert Factory.build(:notification, :delivery_window => 23).valid?
  end

  #----------------------------------------------------------------------------#
  # status:
  #--------
  test "default delivery status is NEW" do
    assert_equal 'NEW', Factory.build(:notification).status
  end

  test "should be invalid unless delivery status is an expected value" do
    assert Factory.build(:notification, :status => 'SHOT').invalid?
  end

  test "delivery status of NEW should be valid" do
    assert Factory.build(:notification, :status => 'NEW').valid?
  end

  test "delivery status of SUCCESS should be valid" do
    assert Factory.build(:notification, :status => 'SUCCESS').valid?
  end

  test "delivery status of TEMP_FAIL should be valid" do
    assert Factory.build(:notification, :status => 'TEMP_FAIL').valid?
  end

  test "delivery status of PERM_FAIL should be valid" do
    assert Factory.build(:notification, :status => 'PERM_FAIL').valid?
  end

  #----------------------------------------------------------------------------#
  # last_run_at:
  #-------------
  test "last run at is optional" do
    assert Factory.build(:notification, :last_run_at => nil).valid?
  end

  test "last run at should hold both a date and a time" do
    now = Time.now
    notification = Factory.build(:notification, :last_run_at => now)
    assert_equal now, notification.last_run_at
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Message:
  #-------------------------
  test "can access message from notification" do
    assert Factory.build(:notification).message
  end

  test "can associate multiple notifications with a message" do
    message = Factory.build(:message)
    message.notifications << Factory.build(:notification)
    message.notifications << Factory.build(:notification)
    assert_equal 2, message.notifications.size
  end

  #----------------------------------------------------------------------------#
  # relationship w/ Notifier:
  #--------------------------
  test "can access notifier from notification" do
    assert Factory.build(:notification).notifier
  end

end
