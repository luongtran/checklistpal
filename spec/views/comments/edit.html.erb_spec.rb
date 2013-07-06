require 'spec_helper'

describe "comments/edit" do
  before(:each) do
    @comment = assign(:comment, stub_model(Comment,
      :task_id => 1,
      :user_id => 1,
      :content => "MyText",
      :parent_id => 1
    ))
  end

  it "renders the edit comment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", comment_path(@comment), "post" do
      assert_select "input#comment_task_id[name=?]", "comment[task_id]"
      assert_select "input#comment_user_id[name=?]", "comment[user_id]"
      assert_select "textarea#comment_content[name=?]", "comment[content]"
      assert_select "input#comment_parent_id[name=?]", "comment[parent_id]"
    end
  end
end
