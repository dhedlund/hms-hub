class DeliverNotificationJob < Struct.new(:notification_id)
  def perform
    notification = Notification.find(notification_id)
    attempt = notification.delivery_attempts.last

    # attempt delivery if never attempted or last was temporary failure
    if !attempt || attempt.result == DeliveryAttempt::TEMP_FAIL
      attempt = DeliveryAttempt.new(:notification => notification)
      attempt.save
    end

    case attempt.result
    when DeliveryAttempt::TEMP_FAIL
      # raise an error so job will be retried later, tracking # of retries
      raise DeliveryAttempt::TEMP_FAIL

    when DeliveryAttempt::ASYNC_DELIVERY
      # enqueue job to check later after response returned from remote server
      Delayed::Job.enqueue(DeliverNotificationJob.new(notification.id))

    else # DELIVERED or PERM_FAIL
      # job should not be retried
    end
  end

end
