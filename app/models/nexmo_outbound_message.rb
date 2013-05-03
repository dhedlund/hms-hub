class NexmoOutboundMessage < ActiveRecord::Base
  belongs_to :delivery_attempt

  attr_accessor :params

  after_update :update_attempt

  # status
  DELIVERED = 'DELIVERED'
  EXPIRED   = 'EXPIRED'
  FAILED    = 'FAILED'
  ACCEPTED  = 'ACCEPTED'
  SUBMITTED = 'ACCEPTED'
  BUFFERED  = 'BUFFERED'
  UNKNOWN   = 'UNKNOWN'

  # error types (used for DeliveryAttempt's :error_type attribute)
  REMOTE_TIMEOUT    = 'REMOTE_TIMEOUT'
  REMOTE_ERROR      = 'REMOTE_ERROR'
  ABSENT_SUBSCRIBER = 'ABSENT_SUBSCRIBER'
  CALL_BARRED       = 'CALL_BARRED'
  PORTABILITY_ERROR = 'PORTABILITY_ERROR'
  ANTI_SPAM         = 'ANTI_SPAM'
  HANDSET_BUSY      = 'HANDSET_BUSY'
  NETWORK_ERROR     = 'NETWORK_ERROR'
  ILLEGAL_NUMBER    = 'ILLEGAL_NUMBER'
  INVALID_MSG       = 'INVALID_MSG'
  UNROUTABLE        = 'UNROUTABLE'
  GENERAL_ERROR     = 'GENERAL_ERROR'
  UNKNOWN_ERROR     = 'UNKNOWN_ERROR'

  validates :delivery_attempt_id, :presence => true
  validates :ext_message_id, :presence => true, :uniqueness => true
  validates :status, :presence => { :on => :update }


  protected

  def update_attempt
    noms = NexmoOutboundMessage.where(:delivery_attempt_id => delivery_attempt_id)

    if noms.all? { |n| n.status == DELIVERED }
      delivery_attempt.update_attributes({ :result => DeliveryAttempt::DELIVERED })

    elsif status == ACCEPTED || status == BUFFERED
      # assuming we'll get another status update later

    elsif status == EXPIRED
      delivery_attempt.update_attributes({
        :result     => DeliveryAttempt::TEMP_FAIL,
        :error_type => REMOTE_TIMEOUT,
        :error_msg  => "expired trying to reach endpoint: #{params.try(:to_json)}",
      })

    elsif status == FAILED || status == UNKNOWN
      # nexmo added a new error code column that's not 

      # error codes from 'err-code' nexmo responses
      case err_code
      when '0' # delivered
        # not really an error, uh...whatever

      when '2' # absent subscriber - temporary
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => ABSENT_SUBSCRIBER,
          :error_msg  => "nexmo returned 'absent subscriber' (2): #{params.try(:to_json)}",
        })

      when '3' # absent subscriber - permenant
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => ABSENT_SUBSCRIBER,
          :error_msg  => "nexmo returned 'absent subscriber' (3): #{params.try(:to_json)}",
        })

      when '4' # call barred by user
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => CALL_BARRED,
          :error_msg  => "nexmo returned 'call barred by user' (4): #{params.try(:to_json)}",
        })

      when '5' # portability error
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => PORTABILITY_ERROR,
          :error_msg  => "nexmo returned 'portability error' (5): #{params.try(:to_json)}",
        })

      when '6' # anti-spam rejection
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => ANTI_SPAM,
          :error_msg  => "nexmo returned 'anti-spam rejection' (6): #{params.try(:to_json)}",
        })

      when '7' # handset busy
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => HANDSET_BUSY,
          :error_msg  => "nexmo returned 'handset busy' (7): #{params.try(:to_json)}",
        })

      when '8' # network error
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => NETWORK_ERROR,
          :error_msg  => "nexmo returned 'network error' (8): #{params.try(:to_json)}",
        })

      when '9' # illegal number
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => ILLEGAL_NUMBER,
          :error_msg  => "nexmo returned 'illegal number' (9): #{params.try(:to_json)}",
        })

      when '10' # invalid message
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => INVALID_MSG,
          :error_msg  => "nexmo returned 'invalid message' (10): #{params.try(:to_json)}",
        })

      when '11' # unroutable
        # this might be a permanent error but we can't tell yet
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => UNROUTABLE,
          :error_msg  => "nexmo returned 'unroutable' (11): #{params.try(:to_json)}",
        })

      when '99' # general error
        # this might be a permanent error but we can't tell yet
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::TEMP_FAIL,
          :error_type => GENERAL_ERROR,
          :error_msg  => "nexmo returned 'general error' (99): #{params.try(:to_json)}",
        })

      else # unknown
        delivery_attempt.update_attributes({
          :result     => DeliveryAttempt::PERM_FAIL,
          :error_type => UNKNOWN_ERROR,
          :error_msg  => "unknown error trying to reach endpoint: #{params.try(:to_json)}",
        })
      end
    end
  end

end
