ActiveAdmin.register Role do
  actions :all, :except => [:destroy, :new]
  config.batch_actions = false
  index do
    selectable_column
    column :name
    column :max_savedlist
    column :max_connections
    default_actions
  end
  filter :name
  form do |f|
    f.inputs "" do
      f.input :max_savedlist
      f.input :max_connections
    end
    f.actions
  end
end