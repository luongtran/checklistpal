class Comment < ActiveRecord::Base
  attr_accessible :content, :parent_id, :task_id, :user_id , :title
  belongs_to :user
  belongs_to :task
  validates_length_of :content, within:  10..160
      
end
