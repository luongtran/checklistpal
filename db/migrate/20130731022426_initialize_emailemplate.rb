class InitializeEmailemplate < ActiveRecord::Migration
  # TYPES = ['welcome_email','upgraded_email','downgraded_email','expire_email','delete_account_email']
  def up
    EmailTemplate.create(:title => "Your subscription has changed",
                         :body => "<h3> Your new subscription details are: </h3>",
                         :email_type => "Upgraded Email"
    )
    EmailTemplate.create(:title => "Your subscription has changed",
                         :body => "<h3> Your new subscription details are: </h3>",
                         :email_type => "Downgraded Email"
    )
    EmailTemplate.create(:title => "Your subscription has expired",
                         :body => "<h3>  Your subscription is now expired due to non-payment. If you have any questions, please contact contact@tudli.com. </h3>",
                         :email_type => "Expire Email"
    )
    EmailTemplate.create(:title => "Your account has been canceled",
                         :body => "<h3>Your account has been cancelled.</h3> <br /> We are sorry to see you go. We'd love to have you back. Visit tudli.com anytime to create a new subscription.",
                         :email_type => "Delete Account Email"
    )
    EmailTemplate.create(:title => "Thank you for your registration",
                         :body => "<h3> Welcome to Tudli.com </h3>",
                         :email_type => "Welcome Email"
    )
  end

  def down
  end
end
