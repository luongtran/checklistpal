ActiveAdmin.register List do
  config.batch_actions = true
  index do
    selectable_column
    id_column
    column :name
    column :user
    column :tasks do |list|
      list.tasks.count
    end
    default_actions
  end
end