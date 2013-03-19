class Notifier < ActiveRecord::Base
  has_many :notifications
  has_and_belongs_to_many :users, :order => :username

  validates :username, :presence => true, :uniqueness => true
  validates :password, :presence => true, :length => { :minimum => 7 }
  validates :name,     :presence => true, :uniqueness => true
  validates :timezone, :presence => true
  validates :active,   :inclusion => [true, false]

  scope :active, lambda { where(:active => true) }

  def self.internal
    find_by_username('internal')
  end

end
