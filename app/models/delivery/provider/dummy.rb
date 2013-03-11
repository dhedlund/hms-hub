class Delivery::Provider::Dummy
  def initialize(config={})
  end

  def deliver(attempt)
    unless attempt.result
      attempt.update_attributes(:result => DeliveryAttempt::DELIVERED)
    end
    true
  end

  def self.delivery_details(delivery_attempt_id)
    nil
  end

end
