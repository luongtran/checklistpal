# == Schema Information
#
# Table name: roles
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  resource_id     :integer
#  resource_type   :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  max_connections :integer
#  max_savedlist   :integer
#

class Role < ActiveRecord::Base
  attr_accessible :name, :max_savedlist, :max_connections
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  validates_numericality_of :max_savedlist, :max_connections
  scopify
end
