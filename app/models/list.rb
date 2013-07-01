class List < ActiveRecord::Base
  include CanCan::Ability
  attr_accessible :name, :user_id ,:description
  belongs_to :user
  has_many :tasks ,  :dependent => :delete_all
  has_many :list_team_members
end
