class RemoveFinishedColumnFromList < ActiveRecord::Migration
  def up
    remove_column :lists, :finished
  end

  def down
  end
end
