class Program < ActiveRecord::Base
  has_many :message_streams

  validates :name,  :presence => true, :uniqueness => true
  validates :title, :presence => true

  default_scope order('name')

end
