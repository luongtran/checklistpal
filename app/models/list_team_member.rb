class ListTeamMember < ActiveRecord::Base
  attr_accessible :active , :invitation_token, :list_id, :user_id
  belongs_to :user
  belongs_to :list
end
