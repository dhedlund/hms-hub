class Message < ActiveRecord::Base
  belongs_to :message_stream
  has_many :notifications

  validates :message_stream_id, :presence => true
  validates :name, :presence => true, :uniqueness => { :scope => :message_stream_id }
  validates :title, :presence => true
  validates :sms_text, :length => { :within => 1..140 }
  validates :offset_days, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  def self.find_by_path(path)
    (sname, mname) = path.to_s.split '/'

    stream_where = MessageStream.where(:name => sname)
    where(:name => mname).joins(:message_stream).merge(stream_where).first
  end

  def path
    message_stream.name + '/' + name rescue nil
  end
end
