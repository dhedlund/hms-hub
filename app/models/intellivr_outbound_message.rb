class IntellivrOutboundMessage < ActiveRecord::Base
  belongs_to :delivery_attempt

  after_update :update_attempt

  COMPLETED     = 'COMPLETED'     # callee answered phone and hung up
  BUSY          = 'BUSY'          # callee phone was busy
  NOANSWER      = 'NOANSWER'      # callee did not answer the phone
  REJECTED      = 'REJECTED'      # callee declined the call
  CONGESTION    = 'CONGESTION'    # network congestion or other network error
  INTERNALERROR = 'INTERNALERROR' # internal INTELLIVR error
  UNKNOWN       = 'UNKNOWN'       # an undocumented status code was returned

  validates :delivery_attempt_id, :presence => true
  validates :ext_message_id, :presence => true, :uniqueness => true
  validates :status, :presence => { :on => :update }


  protected

  def update_attempt
    if status == COMPLETED
      delivery_attempt.update_attributes({ :result => DeliveryAttempt::DELIVERED })

    else
      error_type, error_msg = case status
      when BUSY          then [ BUSY, 'callee phone was busy' ]
      when NOANSWER      then [ NOANSWER, 'callee did not answer the phone' ]
      when REJECTED      then [ REJECTED, 'callee declined the call' ]
      when CONGESTION    then [ CONGESTION, 'network congestion or other network error']
      when INTERNALERROR then [ INTERNALERROR, 'internal INTELLIVR error' ]
      else [ UNKNOWN, "an undocumented status code was returned: #{status}" ]
      end

      delivery_attempt.update_attributes({
        :result     => DeliveryAttempt::TEMP_FAIL,
        :error_type => error_type,
        :error_msg  => error_msg,
      })
    end
  end

end
