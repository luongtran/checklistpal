class EmailTemplate < ActiveRecord::Base
   attr_accessible :title, :body ,:email_type
   TYPES = ['thanks_email','upgraded_email','downgraded_email','expire_email','delete_account_email']
end
