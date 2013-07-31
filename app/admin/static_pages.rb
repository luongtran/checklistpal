ActiveAdmin.register StaticPage do
  menu :label => "About/Support Pages"
  actions :all, :except => [:destroy, :new, :show]
  index do
    column :page_name
    column :title
    default_actions
  end
  filter :page_name
  #show do
  #  h3 static_page.title
  #  div do
  #    raw static_page.content
  #  end
  #end
  form do |f|
    f.inputs "" do
      f.input :title
      f.input :content, :as => :ckeditor
    end
    #f.inputs "Contents" do
    #
    #end
    f.actions
  end
end