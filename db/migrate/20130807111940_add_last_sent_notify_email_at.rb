class AddLastSentNotifyEmailAt < ActiveRecord::Migration
  def up
    add_column :lists, :last_sent_notify_email_at, :datetime
  end

  def down
  end
end
