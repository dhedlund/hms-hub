class CreateMessageStream < ActiveRecord::Migration
  def self.up
    create_table :message_streams do |t|
      t.string :name
      t.string :title

      t.timestamps
    end

    add_index :message_streams, :name, :unique => true
  end

  def self.down
    drop_table :message_streams
  end
end
