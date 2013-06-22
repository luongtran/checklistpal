class CreateCheckListItems < ActiveRecord::Migration
  def change
    
    create_table :tasks do |t|
      t.string :description
      t.datetime :due_date
      t.boolean :completed , :default => false
      t.integer :list_id
      t.timestamps
    end
  end
end
