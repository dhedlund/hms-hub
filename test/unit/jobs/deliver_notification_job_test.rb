require 'test_helper'

class DeliverNotificationJobTest < ActiveSupport::TestCase
  setup do
    @notification = FactoryGirl.create(:notification)
    @job = DeliverNotificationJob.new(@notification.id)
  end

  test "can pass notification_id to constructor" do
    assert DeliverNotificationJob.new(@notification.id)
  end

  test "can access notification_id that was passed to constructor" do
    assert_equal @notification.id, @job.notification_id
  end

  test "responds to: perform" do
    assert_respond_to @job, :perform
  end

# test "calling perform on new notification should create a new delivery attempt" do
#   attempt = mock_attempt(@notification)
#   attempt.expects(:save).returns(true)
#   DeliveryAttempt.expects(:new).once.returns(attempt)
#   @job.perform
# end

  test "calling perform after TEMP_FAIL should create attempt and try again" do
    @notification.stubs(:delivery_attempts).returns([mock_attempt(@notification, :temp_fail)])
    Notification.stubs(:find).returns(@notification)

    attempt = mock_attempt(@notification)
    DeliveryAttempt.expects(:new).once.returns(attempt)
    attempt.expects(:save).returns(true)

    @job.perform
  end

# test "calling perform after ASYNC_DELIVERY should not attempt delivery" do
#   @notification.stubs(:delivery_attempts).returns([mock_attempt(@notification, :async_delivery)])
#   Notification.stubs(:find).returns(@notification)
#   DeliveryAttempt.expects(:new).never
#   @job.perform
# end

  test "calling perform after DELIVERED should not attempt delivery" do
    @notification.stubs(:delivery_attempts).returns([mock_attempt(@notification, :delivered)])
    Notification.stubs(:find).returns(@notification)
    DeliveryAttempt.expects(:new).never
    @job.perform
  end

  test "calling perform after PERM_FAIL should not attempt delivery" do
    @notification.stubs(:delivery_attempts).returns([mock_attempt(@notification, :perm_fail)])
    Notification.stubs(:find).returns(@notification)
    DeliveryAttempt.expects(:new).never
    @job.perform
  end

  test "TEMP_FAIL should cause perform to raise an error (fail the job)" do
    DeliveryAttempt.stubs(:new).returns(mock_attempt(@notification, :temp_fail))
    assert_raise(RuntimeError) { @job.perform }
  end

# test "ASYNC_DELIVERY should cause perform to enqueue a new job" do
#   DeliveryAttempt.stubs(:new).returns(mock_attempt(@notification, :async_delivery))
#   assert_difference('Delayed::Job.count') { @job.perform }
# end

  test "DELIVERED should cause perform to not enqueue a new job" do
    DeliveryAttempt.stubs(:new).returns(mock_attempt(@notification, :delivered))
    assert_no_difference('Delayed::Job.count') { @job.perform }
  end

  test "PERM_FAIL should cause perform to not enqueue a new job" do
    DeliveryAttempt.stubs(:new).returns(mock_attempt(@notification, :perm_fail))
    assert_no_difference('Delayed::Job.count') { @job.perform }
  end


  protected

  def mock_attempt(notification, result=nil)
    r = case result
    when :delivered then DeliveryAttempt::DELIVERED
    when :temp_fail then DeliveryAttempt::TEMP_FAIL
    when :perm_fail then DeliveryAttempt::PERM_FAIL
    when :async_delivery then DeliveryAttempt::ASYNC_DELIVERY
    else result
    end

    attempt = mock()
    attempt.stubs(:notification).returns(notification)
    attempt.stubs(:save).returns(true)
    attempt.stubs(:result).returns(r)
    attempt
  end

end
