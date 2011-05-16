class CreateNotifiers < ActiveRecord::Migration
  def self.up
    create_table :notifiers do |t|
      t.string :username
      t.string :password
      t.string :timezone

      t.datetime :last_login_at
      t.datetime :last_status_req_at

      t.timestamps
    end

    add_index :notifiers, 'username', :unique => true
  end

  def self.down
    drop_table :notifiers
  end
end
