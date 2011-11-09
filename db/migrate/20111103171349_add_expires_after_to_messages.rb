class AddExpiresAfterToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :expire_days, :integer
  end

  def self.down
    remove_column :messages, :expire_days
  end
end
