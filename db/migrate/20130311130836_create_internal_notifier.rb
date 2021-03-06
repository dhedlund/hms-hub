class CreateInternalNotifier < ActiveRecord::Migration
  class Notifier < ActiveRecord::Base
    self.table_name = 'notifiers'
  end

  def up
    Notifier.where(:username => 'internal').first_or_create!(
      :password => SecureRandom.base64(64),
      :timezone => 'UTC',
    )
  end

  def down
    if user = Notifier.where(:username => 'internal').first
      user.delete
    end
  end
end
