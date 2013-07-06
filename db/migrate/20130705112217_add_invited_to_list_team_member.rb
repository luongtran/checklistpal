class AddInvitedToListTeamMember < ActiveRecord::Migration
  def change
    add_column :list_team_members, :invited_id, :integer
  end
end
