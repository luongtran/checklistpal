class Task < ActiveRecord::Base
  attr_accessible :description, :due_date, :completed, :list_id, :position, :hasduedate, :due_date, :user_id
  belongs_to :list
  belongs_to :user
  has_many :comments, :dependent => :destroy
  scope :items, where("list_id is not null").order('position')
  scope :completed, where("completed = ?", true)
  validates_length_of :description, within: 1..160

  acts_as_list

  def self.incompletes(list_id, user_id)
    where('list_id =? AND completed  = ? AND user_id = ?', list_id, false, user_id).order('position')
  end

  def self.completes(list_id, user_id)
    where('list_id =? AND completed  = ? AND user_id = ?', list_id, true, user_id).order('position')
  end
end
