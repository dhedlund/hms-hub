class DeliverNotificationJob < Struct.new(:notification_id)
  def perform
    notification = Notification.find(notification_id)
    attempts = notification.delivery_attempts
    attempt = attempts.last

    if attempts.size >= 3 && attempt.result == DeliveryAttempt::TEMP_FAIL
      notification.update_attributes(:status => Notification::PERM_FAIL)
      return
    end

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
      raise DeliveryAttempt::ASYNC_DELIVERY
      #Delayed::Job.enqueue self, :attempts => 2, :run_at => 1.minute.from_no

    else # DELIVERED or PERM_FAIL
      # job should not be retried
    end
  end

  def reschedule_at(time, attempts);
    time + 1.hour
  end

  def max_attempts
    1000
  end

  def failure
    notification = Notification.find(notification_id)
    notification.update_attributes(:status => Notification::PERM_FAIL)
  end

end
