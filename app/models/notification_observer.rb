class NotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    Delayed::Job.enqueue(DeliverNotificationJob.new(notification.id))
  end

end
