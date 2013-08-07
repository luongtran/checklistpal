ActiveAdmin.register Feedback do
  actions :all, :except => [:new, :edit]
  config.batch_actions = true
  index do
    selectable_column
    id_column
    column :email
    column :content
    column :created_at
    default_actions
  end
end