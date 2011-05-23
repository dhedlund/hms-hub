class AddTimestampsToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :created_at, :datetime
    add_column :notifications, :updated_at, :datetime
  end

  def self.down
    remove_column :notifications, :updated_at
    remove_column :notifications, :created_at
  end
end
