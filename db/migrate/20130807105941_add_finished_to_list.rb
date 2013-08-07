class AddFinishedToList < ActiveRecord::Migration
  def change
    add_column :lists, :finished, :boolean, :default => false
  end
end
