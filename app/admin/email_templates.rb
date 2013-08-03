ActiveAdmin.register EmailTemplate do
  actions :all, :except => [:destroy, :new]
  index do
    column :email_type do |e|
      e.email_type.titleize
    end
    column :title
    default_actions
  end
  show do
    #h3 email_template.title
    div email_template.created_at
    div do
      raw email_template.body
    end
  end
  filter :email_type
  filter :title
  form do |f|
    f.inputs  do
      f.input :title
      f.input :body, as: :wysihtml5, commands: :all, blocks: :all
    end
    f.actions
  end
end