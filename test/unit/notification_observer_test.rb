require 'test_helper'

class NotificationObserverTest < ActiveSupport::TestCase
  setup do
    @notification = Factory.build(:notification)
  end

  test "should enqueue a new delivery job on notification creation" do
    job = mock()
    DeliverNotificationJob.expects(:new).once.returns(job)
    Delayed::Job.expects(:enqueue).with(job).once
    @notification.save!
  end

  test "should not enqueue a new delivery job on notification updates" do
    assert @notification.save
    DeliverNotificationJob.expects(:new).never
    Delayed::Job.expects(:enqueue).never
    @notification.save!
  end

end
