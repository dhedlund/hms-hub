class Notifier < ActiveRecord::Base
  validates :username, :presence => true
  validates :password, :presence => true
  validates :timezone, :presence => true
end
