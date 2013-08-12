# == Schema Information
#
# Table name: list_team_members
#
#  id               :integer          not null, primary key
#  list_id          :integer
#  user_id          :integer
#  active           :boolean          default(FALSE), not null
#  invitation_token :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  invited_id       :integer
#

class ListTeamMember < ActiveRecord::Base
  attr_accessible :active , :invitation_token, :list_id, :user_id, :invited_id
  belongs_to :invite, :class_name => "User"
  belongs_to :user
  belongs_to :list

  
  def self.is_existed_in_connection(user_id, list_id, invited_id)
    return ListTeamMember.find(:all, :conditions => ["user_id = ? AND list_id = ? AND invited_id = ? AND active = ?", user_id, list_id, invited_id, true]).length > 0
  end
end
