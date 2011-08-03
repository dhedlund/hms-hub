class CreateIntellivrOutboundMessages < ActiveRecord::Migration
  def self.up
    create_table :intellivr_outbound_messages do |t|
      t.integer  :delivery_attempt_id
      t.string   :ext_message_id
      t.text     :request
      t.text     :response
      t.text     :callback_res
      t.string   :callee
      t.integer  :duration
      t.string   :status
      t.datetime :connect_at
      t.datetime :disconnect_at

      t.timestamps
    end
  end

  def self.down
    drop_table :intellivr_outbound_messages
  end
end
