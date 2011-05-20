class Notification < ActiveRecord::Base
  belongs_to :message
  belongs_to :notifier

  after_initialize :default_values

  validates :uuid, :presence => true, :uniqueness => { :scope => :notifier_id }
  validates :notifier_id, :presence => true
  validates :message_id, :presence => true
  validates :phone_number, :presence => true
  validates :delivery_method, :inclusion => ['SMS', 'IVR']
  validates :delivery_start, :presence => true
  validates :delivery_window, :numericality => { :allow_nil => true, :only_integer => true, :greater_than => 0, :less_than => 24 }
  validates :status, :inclusion => [ 'NEW', 'SUCCESS', 'TEMP_FAIL', 'PERM_FAIL' ]

  def default_values
    self.status ||= 'NEW'
  end

  def message_path=(path)
    self.message = Message.find_by_path(path)
  end

  def delivery_start=(value)
    if value && !delivery_expires
      write_attribute :delivery_expires, value + 7.days
    end

    write_attribute :delivery_start, value
  end

end
