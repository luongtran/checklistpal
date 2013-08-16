# == Schema Information
#
# Table name: email_templates
#
#  id         :integer          not null, primary key
#  email_type :string(255)
#  title      :string(255)
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailTemplate < ActiveRecord::Base
  attr_accessible :title, :body, :email_type
  TYPES = ['welcome_email', 'upgraded_email', 'downgraded_email', 'expire_email', 'delete_account_email']
  validates_presence_of :title, :body, :email_type

end
