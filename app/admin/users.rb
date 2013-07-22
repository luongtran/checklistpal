ActiveAdmin.register User do
  config.batch_actions = true  
  index do
    selectable_column
    id_column
    column :email
 #   column :role
    column "User plan" do |user| 
      user.roles.first.nil? ? "NULL" : user.roles.first.name
    end
    column "Created" do |user|
      user.lists.count.to_s + " List "+ user.tasks.count.to_s + " Task"
    end
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end
  
  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end