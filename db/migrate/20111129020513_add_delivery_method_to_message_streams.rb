class AddDeliveryMethodToMessageStreams < ActiveRecord::Migration
  def self.up
    add_column :message_streams, :delivery_method, :string
  end

  def self.down
    remove_column :message_streams, :delivery_method
  end
end
