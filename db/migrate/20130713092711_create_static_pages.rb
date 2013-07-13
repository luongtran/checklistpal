class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.boolean :active
      t.string :title
      t.text :content
      t.string :page_name
      t.string :updated_by
      t.string :created_by
      t.timestamps
    end
  end
end
