class User < ActiveRecord::Base
  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :name,     :presence => true
  validates :timezone, :presence => true
  validates :locale,   :presence => true

end
