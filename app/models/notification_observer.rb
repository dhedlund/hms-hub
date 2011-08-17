class NotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    Delayed::Job.enqueue(DeliverNotificationJob.new(notification.id), :run_at => notification.delivery_start)
  end

end
