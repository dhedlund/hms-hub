class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :message_stream_id
      t.string  :name
      t.string  :sms_text
      t.string  :ivr_code
      t.integer :offset_days

      t.timestamps
    end

    add_index :messages, [:message_stream_id, :name], :unique => true
  end

  def self.down
    drop_table :messages
  end
end
