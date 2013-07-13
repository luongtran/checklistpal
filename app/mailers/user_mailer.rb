class UserMailer < ActionMailer::Base
  default :from => "notifications@example.com"
  
  def expire_email(user)
    @user = user
    @template = EmailTemplate.find(:first , :conditions => ["email_type = ?","Expire Email"])
    mail(:to => user.email, :subject => @template.title)
  end
  def thanks_email(user)
    @user = user
    @template = EmailTemplate.find(:first , :conditions => ["email_type = ?","Thanks Email"])
    mail(:to => @user.email, :subject => @template.title)
  end
  def delete_account(user)
    @user = user
    @template = EmailTemplate.find(:first , :conditions => ["email_type = ?","Delete Account Email"])
    mail(:to => @user.email, :subject => @template.title)
  end
  def upgraded(user)
    @user = user
    @template = EmailTemplate.find(:first , :conditions => ["email_type = ?","Upgraded Email"])
    mail(:to => @user.email , :subject => @template.title)
  end
  def downgraded(user)
    @user = user
    @template = EmailTemplate.find(:first , :conditions => ["email_type = ?","Downgraded Email"])
    mail(:to => @user.email , :subject => @template.title)    
  end
end