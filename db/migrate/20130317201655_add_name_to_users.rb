class AddNameToUsers < ActiveRecord::Migration
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
