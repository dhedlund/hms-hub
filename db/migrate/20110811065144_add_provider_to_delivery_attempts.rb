class AddProviderToDeliveryAttempts < ActiveRecord::Migration
  def self.up
    add_column :delivery_attempts, :provider, :string
  end

  def self.down
    remove_column :delivery_attempts, :provider
  end
end
