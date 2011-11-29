class AddLanguageToMessageStreams < ActiveRecord::Migration
  def self.up
    add_column :message_streams, :language, :string
  end

  def self.down
    remove_column :message_streams, :language
  end
end
