class AddDeliveredAtToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :delivered_at, :datetime
  end

  def self.down
    remove_column :notifications, :delivered_at
  end
end
