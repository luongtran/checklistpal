class List < ActiveRecord::Base
  include CanCan::Ability
  attr_accessible :name, :user_id ,:description, :slug
  belongs_to :user
  has_many :tasks ,  :dependent => :delete_all
  has_many :list_team_members,:dependent => :delete_all
  validates_uniqueness_of :slug
  validates_presence_of :name
#  def to_param
#    slug
#  end
end
