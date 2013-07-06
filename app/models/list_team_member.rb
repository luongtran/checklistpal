class ListTeamMember < ActiveRecord::Base
  attr_accessible :active , :invitation_token, :list_id, :user_id, :invited_id
  belongs_to :invite, :class_name => "User"
  belongs_to :user
  belongs_to :list
  
  def self.is_existed_in_connection(user_id, list_id, invited_id)
    return ListTeamMember.find(:all, :conditions => ["user_id = ? AND list_id = ? AND invited_id = ?", user_id, list_id, invited_id]).length > 0
  end
end
