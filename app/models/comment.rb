# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  task_id    :integer
#  user_id    :integer
#  content    :text
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :parent_id, :task_id, :user_id , :title
  belongs_to :user
  belongs_to :task
  validates_length_of :content, within:  10..160
      
end
