class RemoveUniqNameFromMessageStreams < ActiveRecord::Migration
  def self.up
    remove_index :message_streams, :name
    add_index :message_streams, :name
  end

  def self.down
    remove_index :message_streams, :name
    add_index :message_streams, :name, :unique => true
  end
end
