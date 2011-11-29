class CreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
      t.string   :name
      t.string   :title

      t.timestamps
    end

    add_column :message_streams, :program_id, :integer

    add_index :programs, :name, :unique => true
  end

  def self.down
    remove_column :message_streams, :program_id
    drop_table :programs
  end
end
