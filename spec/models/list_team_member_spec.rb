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

require 'spec_helper'

describe ListTeamMember do
  pending "add some examples to (or delete) #{__FILE__}"
end
