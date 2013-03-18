class CreateNotifiersUsers < ActiveRecord::Migration
  def up
    create_table :notifiers_users, :id => false do |t|
      t.integer :notifier_id
      t.integer :user_id
    end

    add_index :notifiers_users, [:user_id, :notifier_id], :unique => true
  end

  def down
    drop_table :notifiers_users
  end
end
