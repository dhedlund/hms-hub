class DeliverNotificationJob < Struct.new(:notification_id)
  def perform
    notification = Notification.find(notification_id)
    attempt = DeliveryAttempt.new(:notification => notification)
    attempt.save
  end

end
