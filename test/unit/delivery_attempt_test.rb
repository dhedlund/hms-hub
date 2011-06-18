require 'test_helper'
require 'mocha'

class DeliveryAttemptTest < ActiveSupport::TestCase
  setup do
    @attempt = Factory.build(:delivery_attempt)
    @notification = @attempt.notification
    @message = @attempt.message
  end

  test "valid delivery attempt should be valid" do
    assert @attempt.valid?
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "should be invalid without a delivery_method" do
    @attempt.delivery_method = nil
    assert @attempt.invalid?
    assert @attempt.errors[:delivery_method].any?
  end

  #----------------------------------------------------------------------------#
  # message:
  #---------
  test "should be invalid without a message_id" do
    @attempt.message_id = nil
    assert @attempt.invalid?
    assert @attempt.errors[:message_id].any?
  end

  test "can access message from delivery attempt" do
    assert @attempt.message
  end

  #----------------------------------------------------------------------------#
  # notification:
  #--------------
  test "should be invalid without a notification_id" do
    @attempt.notification_id = nil
    assert @attempt.invalid?
    assert @attempt.errors[:notification_id].any?
  end

  test "can access notification from delivery attempt" do
    assert @attempt.notification
  end

  test "assigning a notification should set message and message_id" do
    notification = Factory.build(:notification)
    attempt = Factory.build(:delivery_attempt, :notification => nil)
    attempt.notification = notification
    assert_equal notification.message.id, attempt.message.id
    assert_equal notification.message_id, attempt.message_id
  end

  test "assigning a notification should set phone_number" do
    notification = Factory.build(:notification)
    attempt = Factory.build(:delivery_attempt, :notification => nil)
    attempt.notification = notification
    assert_equal notification.phone_number, attempt.phone_number
  end

  test "assigning a notification should set delivery_method" do
    notification = Factory.build(:notification)
    attempt = Factory.build(:delivery_attempt, :notification => nil)
    attempt.notification = notification
    assert_equal notification.delivery_method, attempt.delivery_method
  end

  #----------------------------------------------------------------------------#
  # phone_number:
  #--------------
  test "should be invalid without a phone number" do
    @attempt.phone_number = nil
    assert @attempt.invalid?
    assert @attempt.errors[:phone_number].any?
  end

  #----------------------------------------------------------------------------#
  # result:
  #--------
  test "should be valid if result not specified before create" do
    assert @attempt.new_record?
    @attempt.result = nil
    assert @attempt.valid?
  end

  test "should be invalid if result not specified after create" do
    @attempt.save!
    @attempt.result = nil
    assert @attempt.invalid?
    assert @attempt.errors[:result].any?
  end

  test "should be invalid if result is not an expected result" do
    @attempt.result = 'LOST_IN_TIME'
    assert @attempt.invalid?
    assert @attempt.errors[:result].any?
  end

  test "should be valid if result is TEMP_FAIL" do
    @attempt.save!
    @attempt.result = DeliveryAttempt::TEMP_FAIL
    assert @attempt.valid?
  end

  test "should be valid if result is PERM_FAIL" do
    @attempt.save!
    @attempt.result = DeliveryAttempt::PERM_FAIL
    assert @attempt.valid?
  end

  test "should be valid if result is DELIVERED" do
    @attempt.save!
    @attempt.result = DeliveryAttempt::DELIVERED
    assert @attempt.valid?
  end

  test "should be valid if result is ASYNC_DELIVERY" do
    @attempt.save!
    @attempt.result = DeliveryAttempt::ASYNC_DELIVERY
    assert @attempt.valid?
  end

  #----------------------------------------------------------------------------#
  # save/deliver hooks:
  #--------------------
  test "should attempt delivery on create" do
    @attempt.expects(:deliver).once
    assert_equal true, @attempt.save
  end

  test "should not attempt delivery on updates" do
    @attempt.save!
    @attempt.expects(:deliver).never
    8.times { @attempt.save! }
  end

  test "should update notification with delivery status on success" do
    @attempt.save! # do deliver() first to prevent result being overwritten
    @attempt.result = DeliveryAttempt::DELIVERED
    @attempt.save!

    assert_equal Notification::DELIVERED, @notification.status
    assert_equal @attempt.updated_at, @notification.delivered_at
  end

  test "should update notification with delivery status on failure" do
    ['TEMP_FAIL', 'PERM_FAIL'].each do |result|
      attempt = Factory.create(:delivery_attempt)
      notification = attempt.notification
      attempt.update_attributes(
        :result     => result,
        :error_type => 'CONNECTION_LOST',
        :error_msg  => 'Remote server disconnected.'
      )

      assert_equal attempt.result, notification.status
      assert_equal attempt.error_type, notification.last_error_type
      assert_equal attempt.error_msg, notification.last_error_msg
      assert_equal attempt.updated_at, notification.last_run_at
    end
  end

  test "should not update notification status if response is ASYNC_DELIVERY" do
    @attempt.save! # do deliver() first to prevent result being overwritten
    @attempt.result = DeliveryAttempt::ASYNC_DELIVERY
    @attempt.save!

    assert_not_equal @attempt.result, @notification.status
  end

end
