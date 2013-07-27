ActiveAdmin.register Role do
  config.batch_actions = false
  index do
    selectable_column
    id_column
    column :name
    column :max_savedlist
    column :max_connections
    default_actions
  end
  form do |f|
    f.inputs "Roles Detail" do
      f.input :name
      f.input :max_savedlist
      f.input :max_connections
    end
    f.actions
  end
end