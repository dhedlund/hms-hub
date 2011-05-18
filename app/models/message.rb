class Message < ActiveRecord::Base
  belongs_to :message_stream
  has_many :notifications

  validates :message_stream_id, :presence => true
  validates :name, :presence => true, :uniqueness => { :scope => :message_stream_id }
  validates :sms_text, :length => { :within => 1..140 }
  validates :offset_days, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
end
