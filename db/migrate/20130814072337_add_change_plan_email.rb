class AddChangePlanEmail < ActiveRecord::Migration
  def up
    EmailTemplate.create(:title => "Your subscription has changed",
                         :body => "<h3> Your new subscription details are: </h3>",
                         :email_type => "Change Plan Email"
    )

  end

  def down
  end
end
