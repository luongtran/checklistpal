class Comment < ActiveRecord::Base
  attr_accessible :content, :parent_id, :task_id, :user_id , :title
  belongs_to :user
  belongs_to :task
      
end
