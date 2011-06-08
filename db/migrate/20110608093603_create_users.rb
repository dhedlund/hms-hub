class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :timezone

      t.timestamps
    end

    add_index :users, :username, :unique => true
  end

  def self.down
    drop_table :users
  end
end
