class AddLastCompletedMarkAt < ActiveRecord::Migration
  def up
    add_column :lists, :last_completed_mark_at, :datetime
  end

  def down
  end
end
