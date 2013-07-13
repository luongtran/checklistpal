class UserMailer < ActionMailer::Base
  default :from => "notifications@example.com"
  
  def expire_email(user)
    mail(:to => user.email, :subject => "Subscription Cancelled")
  end
  def thanks_email(user)
    mail(:to => user.email, :subject => "Thanks for subcribing !")
  end
  def delete_account(user)
    mail(:to => user.email, :subject => "You account have been deleted")
  end
  def upgraded
    mail(:to => user.email , :subject => "You account has been upgraded to PAID plan")
  end
  def downgraded
    mail(:to => user.email , :subject => "You account has been downgraded to FREE plan")
  end
end