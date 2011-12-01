require 'uuid'

class Message < ActiveRecord::Base
  belongs_to :message_stream
  has_many :notifications

  before_create :generate_uuid

  validates :message_stream_id, :presence => true
  validates :name, :presence => true, :uniqueness => { :scope => :message_stream_id }
  validates :title, :presence => true
  validates :sms_text, :length => { :minimum => 1, :allow_nil => true }
  validates :offset_days, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  default_scope order('offset_days')

  def self.find_by_path(path)
    %r{^([^/]+)/([^/]+)$} =~ path or return
    stream = MessageStream.find_by_name($1) or return
    stream.messages.find_by_name($2)
  end

  def path
    "#{message_stream.name}/#{name}" if message_stream.name && name
  end

  def sms_text(variables=nil)
    return unless self[:sms_text]
    return self[:sms_text] unless variables

    # interpolates text, replacing %xyz% with variables[xyz] for each variable
    variables.inject(self[:sms_text]) { |r,(k,v)| r.gsub("%#{k}%", v) }
  end


  protected

  def generate_uuid
    write_attribute :uuid, UUID.generate
  end

end
