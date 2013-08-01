class UserMailer < ActionMailer::Base
  default :from => "admin@tudli.com"
  # TYPES = ['welcome_email','upgraded_email','downgraded_email','expire_email','delete_account_email']
  def welcome_email(user)
    @user = user
    #@template = EmailTemplate.find(:first, :conditions => ["email_type = ?", "Welcome Email"])
    @template = EmailTemplate.where(email_type: "Welcome Email").first
    mail(:to => @user.email, :subject => @template.title)
  end

  def expire_email(user)
    @user = user
    @template = EmailTemplate.where(email_type: "Expire Email").first
    mail(:to => user.email, :subject => @template.title)
  end

  #def thanks_email(user)
  #  @user = user
  #  @template = EmailTemplate.where(email_type: "Thanks Email").first
  #  mail(:to => @user.email, :subject => @template.title)
  #end

  def delete_account(user)
    @user = user
    #@template = EmailTemplate.find(:first, :conditions => ["email_type = ?", "Delete Account Email"])
    @template = EmailTemplate.where(email_type: "Delete Account Email").first
    mail(:to => @user.email, :subject => @template.title)
  end

  def upgraded(user)
    @user = user
    #@template = EmailTemplate.find(:first, :conditions => ["email_type = ?", "Upgraded Email"])
    @template = EmailTemplate.where(email_type: "Upgraded Email").first
    mail(:to => @user.email, :subject => @template.title)
  end

  def downgraded(user)
    @user = user
    while @user.lists.count > 3
      @user.lists.first.destroy
    end
    #@template = EmailTemplate.find(:first, :conditions => ["email_type = ?", "Downgraded Email"])
    @template = EmailTemplate.where(email_type: "Downgraded Email").first
    mail(:to => @user.email, :subject => @template.title)
  end


  ### Test
  def test_mail(dest_email)
    puts "\n\n___Create test e-mail to #{dest_email}"
    mail(:to => "#{dest_email}", :subject => "Hello")
  end
end