class ChangeNotificationsDeliveryWindowType < ActiveRecord::Migration
  def self.up
    change_column :notifications, :delivery_window, :integer
  end

  def self.down
    change_column :notifications, :delivery_window, :string
  end
end
