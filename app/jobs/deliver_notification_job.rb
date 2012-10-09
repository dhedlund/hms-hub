class DeliverNotificationJob < Struct.new(:notification_id)
  def perform
    notification = Notification.find(notification_id)
    attempts = notification.delivery_attempts
    attempt = attempts.last

    if notification.delivery_expires < Time.zone.now
      # past notification's expiration date

      if notification.delivery_expires < 7.days.ago
        # something got lost and we're tired of waiting
        notification.update_attributes(:status => Notification::PERM_FAIL)
        return

      elsif attempt && attempt.result == DeliveryAttempt::TEMP_FAIL
        # last attempt failed and now we're expired so don't try again
        notification.update_attributes(:status => Notification::PERM_FAIL)
        return
      end
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
    notification = Notification.find(notification_id)
    time_offset = notification.delivery_start - notification.delivery_start.beginning_of_day
    today_start = Time.zone.now.beginning_of_day + time_offset
    today_end = today_start + 5.hours # notification.delivery_window.hours

    next_run_at = time + 1.hour
    if next_run_at < today_start
      next_run_at = today_start + rand(3000).seconds # 50 minutes
    elsif next_run_at >= today_end
      next_run_at = today_start + 1.day + rand(3000).seconds
    end

    next_run_at
  end

  def max_attempts
    1000
  end

  def failure
    notification = Notification.find(notification_id)
    notification.update_attributes(:status => Notification::PERM_FAIL)
  end

end
