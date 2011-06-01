class DeliveryAttempt < ActiveRecord::Base
  belongs_to :notification
  has_one :message

  before_validation :cache_notification_data
  before_save :deliver, :unless => :result?

  validates :notification_id, :presence => true
  validates :message_id, :presence => true
  validates :phone_number, :presence => true
  validates :delivery_method, :presence => true

  alias_method :orig_notification=, :notification=
  def notification=(value)
    self.orig_notification=(value)
    self.cache_notification_data
  end


  protected

  def cache_notification_data
    self.message = notification.try(:message)
    self.message_id = notification.try(:message_id)
    self.phone_number = notification.try(:phone_number)
    self.delivery_method = notification.try(:delivery_method)
  end

  def deliver
    return false if result

    self.result = 'SUCCESS'

    return true
  end

end
