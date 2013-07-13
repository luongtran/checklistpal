# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :static_page do
    active false
    title "MyString"
    content "MyText"
    page_name "MyString"
    update_by "MyString"
  end
end
