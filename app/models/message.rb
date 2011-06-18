class Message < ActiveRecord::Base
  belongs_to :message_stream
  has_many :notifications

  validates :message_stream_id, :presence => true
  validates :name, :presence => true, :uniqueness => { :scope => :message_stream_id }
  validates :title, :presence => true
  validates :sms_text, :length => { :within => 1..160 }, :allow_nil => true
  validates :offset_days, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  def self.find_by_path(path)
    %r{^([^/]+)/([^/]+)$} =~ path or return
    stream = MessageStream.find_by_name($1) or return
    stream.messages.find_by_name($2)
  end

  def path
    "#{message_stream.name}/#{name}" if message_stream.name && name
  end
end
