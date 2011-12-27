class AddDeliveryMethodToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :delivery_method, :string
  end

  def self.down
    remove_column :messages, :delivery_method
  end
end
