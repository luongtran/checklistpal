ActiveAdmin.register StaticPage do
  index do                            
    column :title  
    column :page_name
    column :active
    default_actions                   
  end
  show do
      h3 static_page.title
      div do
        raw static_page.content
      end
    end
  form do |f|
    f.inputs "Select Pages" do
      f.select :page_name, StaticPage::PAGE_NAMES.collect { |s| [s.titleize] }, {:prompt=>"------------Select page to edit -----------"} ,:style => "width:100%"      
    end
    f.inputs "Details" do
      f.input :title
    end
    f.inputs "Contents" do
      f.input :content ,:as => :ckeditor
    end
    f.input :active
    f.actions
  end
end