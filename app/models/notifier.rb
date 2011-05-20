class Notifier < ActiveRecord::Base
  has_many :notifications

  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :timezone, :presence => true
end
