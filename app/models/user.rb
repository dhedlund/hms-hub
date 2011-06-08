class User < ActiveRecord::Base
  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :timezone, :presence => true
end
