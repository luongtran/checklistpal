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

require File.dirname(__FILE__) + '/../spec_helper'

describe Authentication do
  it "should be valid" do
    Authentication.new.should be_valid
  end
end
