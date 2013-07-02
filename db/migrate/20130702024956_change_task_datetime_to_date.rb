class ChangeTaskDatetimeToDate < ActiveRecord::Migration
  def change
  	change_column :tasks , :due_date , :date
  end


end
