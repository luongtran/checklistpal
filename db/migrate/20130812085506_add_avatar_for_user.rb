class AddAvatarForUser < ActiveRecord::Migration
  def up
    add_column :users, :avatar_url, :string
  end

  def down
  end
end
