class FixNotificationUuidUniqueness < ActiveRecord::Migration
  def self.up
    remove_index :notifications, :uuid
    add_index :notifications, [:notifier_id, :uuid], :unique => true
  end

  def self.down
    remove_index :notifications, [:notifier_id, :uuid]
    add_index :notifications, :uuid, :unique => true
  end
end
