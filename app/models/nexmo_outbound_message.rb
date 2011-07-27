class NexmoOutboundMessage < ActiveRecord::Base
  belongs_to :delivery_attempt

  attr_accessor :params

  after_update :update_attempt

  DELIVERED = 'DELIVERED'
  BUFFERED = 'BUFFERED'
  EXPIRED = 'EXPIRED'
  FAILED = 'FAILED'

  # error types (used for DeliveryAttempt's :error_type attribute)
  REMOTE_TIMEOUT = 'REMOTE_TIMEOUT'
  REMOTE_ERROR = 'REMOTE_ERROR'

  validates :delivery_attempt_id, :presence => true
  validates :ext_message_id, :presence => true, :uniqueness => true
  validates :status, :presence => { :on => :update }


  protected

  def update_attempt
    noms = NexmoOutboundMessage.where(:delivery_attempt_id => delivery_attempt_id)

    if noms.all? { |n| n.status == DELIVERED }
      delivery_attempt.update_attributes({ :result => DeliveryAttempt::DELIVERED })

    elsif status == EXPIRED
      delivery_attempt.update_attributes({
        :result     => DeliveryAttempt::TEMP_FAIL,
        :error_type => REMOTE_TIMEOUT,
        :error_msg  => "expired trying to reach endpoint: #{params.try(:to_json)}",
      })

    elsif status == FAILED
      delivery_attempt.update_attributes({
        :result     => DeliveryAttempt::PERM_FAIL,
        :error_type => REMOTE_ERROR,
        :error_msg  => "failed trying to reach endpoint: #{params.try(:to_json)}",
      })
    end
  end

end
