class User < ActiveRecord::Base
  has_and_belongs_to_many :notifiers, :order => :username

  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true, :length => { :minimum => 7 }
  validates :name,     :presence => true
  validates :timezone, :presence => true
  validates :locale,   :presence => true

end
