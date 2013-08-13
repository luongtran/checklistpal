class ChangeAvatarColumnFromUsersTable < ActiveRecord::Migration
  def up
    rename_column :users, :avatar_url, :avatar_file_name
  end

  def down
  end
end
