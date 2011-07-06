class NexmoOutboundMessage < ActiveRecord::Base
  belongs_to :delivery_attempt

  validates :delivery_attempt_id, :presence => true
  validates :ext_message_id, :presence => true, :uniqueness => true
  validates :status, :presence => { :on => :update }
end
