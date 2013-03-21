class AddNameToNotifiers < ActiveRecord::Migration
  class Notifier < ActiveRecord::Base
    self.table_name = 'notifiers'
  end

  def up
    add_column :notifiers, :name, :string

    Notifier.scoped.each do |notifier|
      notifier.update_attributes(:name => notifier.username.titleize)
    end
  end

  def down
    remove_column :notifiers, :name
  end
end
