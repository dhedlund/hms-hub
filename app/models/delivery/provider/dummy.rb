class Delivery::Provider::Dummy
  def initialize(config={})
  end

  def deliver(attempt)
    attempt.update_attributes({ :result => DeliveryAttempt::DELIVERED })
    true
  end

end
