class AddHasDueDateToTask < ActiveRecord::Migration
  def change
    
    add_column :tasks , :hasduedate , :boolean , :default => false
  end
end
