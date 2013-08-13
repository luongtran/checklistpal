class AddAvatarUrl < ActiveRecord::Migration
  def up
    add_column :users, :avatar_s3_url, :text
    add_column :users, :avatar_url_expires_at, :datetime
  end

  def down
  end
end
