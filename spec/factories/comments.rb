# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    task_id 1
    user_id 1
    content "MyText"
    parent_id 1
  end
end