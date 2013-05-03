class AddNewNexmoFields < ActiveRecord::Migration
  def up
    add_column :nexmo_outbound_messages, :sender_id, :string
    add_column :nexmo_outbound_messages, :err_code, :string
    add_column :nexmo_outbound_messages, :price, :string
    add_column :nexmo_outbound_messages, :client_ref, :string
  end

  def down
    remove_column :nexmo_outbound_messages, :sender_id
    remove_column :nexmo_outbound_messages, :err_code
    remove_column :nexmo_outbound_messages, :price
    remove_column :nexmo_outbound_messages, :client_ref
  end

end
