class DeliveryAttempt < ActiveRecord::Base
  belongs_to :notifier
  belongs_to :notification
  belongs_to :message

  after_create :deliver
  after_save :update_notification, :if => :result?

  TEMP_FAIL = 'TEMP_FAIL'
  PERM_FAIL = 'PERM_FAIL'
  DELIVERED = 'DELIVERED'
  ASYNC_DELIVERY = 'ASYNC_DELIVERY'
  VALID_RESULTS = [ TEMP_FAIL, PERM_FAIL, DELIVERED, ASYNC_DELIVERY ]

  # error types
  UNSUPPORTED_PROVIDER = 'UNSUPPORTED_PROVIDER'

  validates :message_id, :presence => true
  validates :notifier_id, :presence => true
  validates :phone_number, :presence => true
  validates :delivery_method, :presence => true
  validates :result, :on => :create, :inclusion => VALID_RESULTS, :allow_nil => true
  validates :result, :on => :update, :inclusion => VALID_RESULTS

  alias_method :orig_notification=, :notification=
  def notification=(value)
    self.orig_notification=(value)
    self.cache_notification_data
  end

  def provider
    begin
      self[:provider].constantize if self[:provider]
    rescue NameError
      nil
    end
  end

  def provider=(p)
    self[:provider] = p.to_s
    self[:provider].constantize # throws NameError if not class
  end

  def delivery_details
    self.provider.delivery_details(id) if self.provider
  end


  protected

  def cache_notification_data
    self.message = notification.try(:message)
    self.message_id = notification.try(:message_id)
    self.notifier = notification.try(:notifier)
    self.notifier_id = notification.try(:notifier_id)
    self.phone_number = notification.try(:phone_number)
    self.delivery_method = notification.try(:delivery_method)
  end

  def deliver
    provider = Delivery::Agent.instance[delivery_method.downcase]
    unless provider
      self.result = PERM_FAIL
      self.error_type = UNSUPPORTED_PROVIDER
      self.error_msg = "unsupported delivery provider '#{delivery_method}'"
      return save
    end

    self.provider = provider.class
    provider.deliver(self)
  end

  def update_notification
    return unless notification

    # if async, don't want to tell notifier until we get back a real result
    return if result == ASYNC_DELIVERY

    notification.update_attributes(
      :status          => result,
      :last_run_at     => updated_at,
      :last_error_type => error_type,
      :last_error_msg  => error_msg,
      :delivered_at    => (result == DELIVERED ? updated_at : nil)
    )
  end

end
