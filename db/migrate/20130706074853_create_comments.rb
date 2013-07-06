class CreateComments < ActiveRecord::Migration
  def change
   
    create_table :comments do |t|
      t.string :title
      t.integer :task_id
      t.integer :user_id
      t.text :content
      t.integer :parent_id

      t.timestamps
    end
  end
end
