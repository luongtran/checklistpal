ActiveAdmin.register Feedback do
  actions :all, :except => [:new]
  config.batch_actions = true
  index do
    id_column
    column :email
    column :content
    column :created_at
    default_actions
  end
end