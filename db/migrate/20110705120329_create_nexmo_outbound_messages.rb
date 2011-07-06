class CreateNexmoOutboundMessages < ActiveRecord::Migration
  def self.up
    create_table :nexmo_outbound_messages do |t|
      t.integer  :delivery_attempt_id
      t.string   :ext_message_id
      t.string   :to_msisdn
      t.string   :network_code
      t.string   :mo_tag
      t.string   :status
      t.string   :scts

      t.timestamps
    end

    add_index :nexmo_outbound_messages, :delivery_attempt_id
    add_index :nexmo_outbound_messages, :ext_message_id, :unique => true
  end

  def self.down
    drop_table :nexmo_outbound_messages
  end
end
