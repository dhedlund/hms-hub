class AddTitleToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :title, :string
  end

  def self.down
    remove_column :messages, :title
  end
end
