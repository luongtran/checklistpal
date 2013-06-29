class AddColumnToRoles < ActiveRecord::Migration
  def change
    add_column :roles , :max_connections , :integer
    add_column :roles , :max_savedlist , :integer
  end
end