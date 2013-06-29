class Role < ActiveRecord::Base
  attr_accessible :name , :max_savedlist , :max_connections
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  scopify
end
