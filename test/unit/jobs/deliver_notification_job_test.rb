require 'test_helper'
require 'mocha'

class DeliverNotificationJobTest < ActiveSupport::TestCase
  setup do
    @notification_id = 874
    @job = DeliverNotificationJob.new(@notification_id)
  end

  test "can pass notification_id to constructor" do
    assert DeliverNotificationJob.new(@notification_id)
  end

  test "can access notification_id that was passed to constructor" do
    assert_equal @notification_id, @job.notification_id
  end

  test "responds to: perform" do
    assert_respond_to @job, :perform
  end

  test "calling perform creates and saves (delivers) a new delivery attempt" do
    notification = Factory.create(:notification, :id => @notification_id)

    attempt = mock()
    attempt.expects(:save).once
    DeliveryAttempt.expects(:new).once.returns(attempt)
    @job.perform
  end

end
