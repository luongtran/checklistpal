class CreateListTeamMembers < ActiveRecord::Migration
  def change
    create_table :list_team_members do |t|
      t.integer :list_id
      t.integer :user_id
      t.boolean :active      ,  :default => false, :null => false
      t.string :invitation_token

      t.timestamps
    end
  end
end
