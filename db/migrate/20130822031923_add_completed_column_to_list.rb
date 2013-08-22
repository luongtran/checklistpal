class AddCompletedColumnToList < ActiveRecord::Migration
  def change
    add_column :lists, :completed, :boolean, :default => false
  end
end
