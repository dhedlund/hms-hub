class NexmoInboundMessage < ActiveRecord::Base
  validates :ext_message_id, :presence => true, :uniqueness => true
  validates :to_msisdn, :presence => true
  validates :mo_tag, :presence => true
  validates :text, :presence => true
end
