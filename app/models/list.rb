class List < ActiveRecord::Base
  attr_accessible :name, :user_id ,:description
  belongs_to :user
  has_many :tasks ,  :dependent => :delete_all
  
end
