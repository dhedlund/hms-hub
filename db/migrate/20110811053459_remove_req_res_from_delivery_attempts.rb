class RemoveReqResFromDeliveryAttempts < ActiveRecord::Migration
  def self.up
    remove_index :delivery_attempts, [:delivery_method, :created_at]
    remove_column :delivery_attempts, :request
    remove_column :delivery_attempts, :response
    add_index :delivery_attempts, [:delivery_method, :created_at], :name => 'idx_delivery_method_created_at'
  end

  def self.down
    remove_index :delivery_attempts, :name => 'idx_delivery_method_created_at'
    add_column :delivery_attempts, :request, :text
    add_column :delivery_attempts, :response, :text
    add_index :delivery_attempts, [:delivery_method, :created_at]
  end
end
