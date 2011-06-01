class CreateDeliveryAttempts < ActiveRecord::Migration
  def self.up
    create_table :delivery_attempts do |t|
      t.integer  :notification_id

      t.string   :phone_number
      t.string   :delivery_method
      t.string   :message_id

      t.text     :request
      t.text     :response
      t.string   :result
      t.string   :error_type
      t.text     :error_msg

      t.timestamps
    end

    add_index :delivery_attempts, :notification_id
    add_index :delivery_attempts, [:delivery_method, :created_at]
  end

  def self.down
    drop_table :delivery_attempts
  end
end
