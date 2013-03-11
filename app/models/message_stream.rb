class MessageStream < ActiveRecord::Base
  has_many :messages, :order => 'offset_days, name'

  validates :name,  :presence => true, :uniqueness => true
  validates :title, :presence => true

  default_scope order('name')

end
