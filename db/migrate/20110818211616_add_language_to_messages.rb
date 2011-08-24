class AddLanguageToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :language, :string
  end

  def self.down
    remove_column :messages, :language
  end
end
