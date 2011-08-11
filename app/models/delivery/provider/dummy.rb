class Delivery::Provider::Dummy
  def initialize(config={})
  end

  def deliver(attempt)
    attempt.update_attributes({ :result => DeliveryAttempt::DELIVERED })
    true
  end

  def self.delivery_details(delivery_attempt_id)
    nil
  end

end
