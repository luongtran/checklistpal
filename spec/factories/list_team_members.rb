# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list_team_member do
    list_id 1
    user_id 1
    active false
    invitation_token "MyString"
  end
end
