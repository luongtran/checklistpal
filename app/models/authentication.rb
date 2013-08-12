# == Schema Information
#
# Table name: authentications
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  provider     :string(255)
#  uid          :string(255)
#  token        :string(255)
#  token_secret :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid,:token, :token_secret
  belongs_to :user
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      authentication.provider = auth.provider
      authentication.uid = auth.uid
      authentication.token = auth.token
      authentication.token_secret = auth.token_secret
    end
  end
end
