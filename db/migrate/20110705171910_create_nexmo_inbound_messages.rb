class CreateNexmoInboundMessages < ActiveRecord::Migration
  def self.up
    create_table :nexmo_inbound_messages do |t|
      t.string   :ext_message_id
      t.integer  :multipart_start_id
      t.string   :to_msisdn
      t.string   :mo_tag
      t.text     :text

      t.timestamps
    end

    add_index :nexmo_inbound_messages, :ext_message_id, :unique => true
    add_index :nexmo_inbound_messages, :multipart_start_id
  end

  def self.down
    drop_table :nexmo_inbound_messages
  end
end
