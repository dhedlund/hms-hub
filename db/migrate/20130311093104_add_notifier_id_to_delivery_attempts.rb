class AddNotifierIdToDeliveryAttempts < ActiveRecord::Migration
  def up
    add_column :delivery_attempts, :notifier_id, :integer
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE delivery_attempts
        JOIN notifications ON delivery_attempts.notification_id = notifications.id
        SET delivery_attempts.notifier_id = notifications.notifier_id
    SQL
  end

  def down
    remove_column :delivery_attempts, :notifier_id
  end
end
