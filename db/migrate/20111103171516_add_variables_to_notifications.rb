class AddVariablesToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :variables, :text
  end

  def self.down
    remove_column :notifications, :variables
  end
end
