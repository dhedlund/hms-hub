class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string   :uuid
      t.integer  :notifier_id
      t.integer  :message_id
      t.string   :first_name
      t.string   :phone_number
      t.string   :delivery_method
      t.datetime :delivery_start
      t.datetime :delivery_expires
      t.string   :delivery_window
      t.string   :status
      t.string   :last_error_type
      t.text     :last_error_msg
      t.datetime :last_run_at
    end

    add_index :notifications, :uuid, :unique => true
    add_index :notifications, [:last_run_at, :notifier_id]
  end

  def self.down
    drop_table :notifications
  end
end
