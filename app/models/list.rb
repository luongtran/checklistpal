class List < ActiveRecord::Base
  include CanCan::Ability
  attr_accessible :name, :user_id ,:description
  belongs_to :user
  has_many :tasks ,  :dependent => :delete_all
  has_many :my_connections , :dependent => :destroy
  #before_save :check_permission
  
#  def self.check_permission
#    if !self.user_id.blank?
#      @user = User.find(user_id)
#      return if @user.has_role? :admin , :paid
#        if(@user.has_role? :free)
#          if(@user.lists.count < 3)
#            true
#            flash[:notice] = "You list created"
#          else
#            raise "Free member can only have 3 save list. Please update to Paid member to create unlimited !!!!."
#            false
#          end
#        end
#    else
#      true
#    end
#  end
end
