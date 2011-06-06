require 'test_helper'
require 'mocha'

class DeliverNotificationJobTest < ActiveSupport::TestCase
  test "can pass notification_id to constructor" do
    assert DeliverNotificationJob.new(874)
  end

  test "can access notification_id that was passed to constructor" do
    assert_equal 874, DeliverNotificationJob.new(874).notification_id
  end

  test "responds to: perform" do
    assert_respond_to DeliverNotificationJob.new, :perform
  end

  test "calling perform create and saves (delivers) a new delivery attempt" do
    notification = Factory.create(:notification)

    attempt = mock()
    DeliveryAttempt.expects(:new).once.returns(attempt)
    attempt.expects(:save).once

    job = DeliverNotificationJob.new(notification.id)
    job.perform
  end

end
