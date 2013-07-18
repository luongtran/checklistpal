ActiveAdmin.register EmailTemplate do
  index do                            
    column :email_type  
    column :title
    default_actions                   
  end
  show do
      h3 email_template.title
      div email_template.created_at
      div do
        raw email_template.body
      end
    end
  form do |f|
    f.inputs "Select Pages" do
      f.select :email_type, EmailTemplate::TYPES.collect { |s| [s.titleize] }, {:prompt=>"------------Select page to edit -----------"} ,:style => "width:100%"      
    end
    f.inputs "Details" do
      f.input :title
    end
    f.inputs "Contents" do
      f.input :body ,:as => :ckeditor
    end
    
    f.actions
  end
end