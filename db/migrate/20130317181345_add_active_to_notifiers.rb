class AddActiveToNotifiers < ActiveRecord::Migration
  def change
    add_column :notifiers, :active, :boolean, :default => true
  end
end
