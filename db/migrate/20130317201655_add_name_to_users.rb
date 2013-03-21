class AddNameToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    self.table_name = 'users'
  end

  def up
    add_column :users, :name, :string

    User.scoped.each do |user|
      user.update_attributes(:name => user.username.titleize)
    end
  end

  def down
    remove_column :users, :name
  end
end
