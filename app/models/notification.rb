class Notification < ActiveRecord::Base
  belongs_to :message
  belongs_to :notifier
  has_many :delivery_attempts

  after_initialize :default_values

  NEW = 'NEW'
  TEMP_FAIL = 'TEMP_FAIL'
  PERM_FAIL = 'PERM_FAIL'
  DELIVERED = 'DELIVERED'
  CANCELLED = 'CANCELLED'
  VALID_STATUSES = [ NEW, TEMP_FAIL, PERM_FAIL, DELIVERED, CANCELLED ]

  SMS = 'SMS'
  IVR = 'IVR'
  VALID_DELIVERY_METHODS = [ SMS, IVR ]

  WINDOW_SIZE   = 4  # default delivery window size, in hours
  WINDOW_START  = 14 # default delivery start hour, in hours
  EXPIRES_AFTER = 7  # default expiration date offset, in days
  EARLIEST_HOUR = 9  # earliest a notification can be delivered, in hours
  LATEST_HOUR   = 21 # latest a notification can be delivered, in hours

  serialize :variables

  validates :uuid, :presence => true, :uniqueness => { :scope => :notifier_id }
  validates :notifier_id, :presence => true
  validates :message_id, :presence => true
  validates :phone_number, :presence => true
  validates :delivery_method, :inclusion => VALID_DELIVERY_METHODS
  validates :delivery_start, :presence => true
  validates :delivery_window, :numericality => {
    :only_integer => true,
    :greater_than_or_equal_to => 2,
    :less_than_or_equal_to => 12
  }
  validates :status, :inclusion => VALID_STATUSES

  scope :run, where('last_run_at is not null')
  scope :run_since, lambda { |f| run.where('last_run_at > ?', f) }

  def default_values
    self.status ||= 'NEW'
    self.delivery_window ||= WINDOW_SIZE
  end

  def delivery_expires
    self[:delivery_expires] ||= delivery_start.try(:+, EXPIRES_AFTER.days)
  end

  def variables
    self[:variables] || {}
  end

  def message_path=(path)
    self.message = Message.find_by_path(path)
  end

  def get_delivery_range
    return nil unless delivery_start && delivery_expires && delivery_window

    start = delivery_start.in_time_zone(notifier.timezone)
    expires = delivery_expires.in_time_zone(notifier.timezone)

    [
      start.strftime("%Y-%m-%d"),
      expires.strftime("%Y-%m-%d"),
      "#{start.hour}-#{start.hour + delivery_window}"
    ]
  end

  def set_delivery_range(start, expires = nil, preferred_time = nil)
    begin
      Time.use_zone(notifier.timezone) do
        start = Date.parse(start.to_s).midnight
        expires = Date.parse(expires.to_s).midnight if expires
        expires ||= start + EXPIRES_AFTER.days

        # calculate preferred time range as: window_start + window_size
        window_size = WINDOW_SIZE
        window_start = WINDOW_START
        if preferred_time =~ /^(\d+)-(\d+)$/
          start_hour = $1.to_i > EARLIEST_HOUR ? $1.to_i : EARLIEST_HOUR
          end_hour = $2.to_i < LATEST_HOUR ? $2.to_i : LATEST_HOUR
          if (end_hour - start_hour) >= 2
            window_start = start_hour
            window_size = end_hour - start_hour
          end
        end

        self.delivery_start = start + window_start.hours
        self.delivery_expires = expires
        self.delivery_window = window_size
      end

      true
    rescue ArgumentError
      false
    end
  end

end
