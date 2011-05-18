class MessageStream < ActiveRecord::Base
  has_many :messages

  validates :name,  :presence => true, :uniqueness => true
  validates :title, :presence => true
end
