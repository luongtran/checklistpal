ActiveAdmin.register Task do
  scope :all, :default => true
  scope :due_this_week do |tasks|
    tasks.where('due_date > ? and due_date < ?', Time.now, 1.week.from_now)
  end
  scope :late do |tasks|
    tasks.where('due_date < ?', Time.now)
  end
  config.batch_actions = true
  index do
    selectable_column
    id_column
    column :description
    column :completed
    column :list
    column :user
    default_actions
  end
end