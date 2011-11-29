class MessageStream < ActiveRecord::Base
  has_many :messages
  belongs_to :program

  validates :name,  :presence => true, :uniqueness => true
  validates :title, :presence => true
  validates :delivery_method, :presence => true

  default_scope order('name')

end
