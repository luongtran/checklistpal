Checklistpal::Application.routes.draw do

  match '/auth/:provider/callback' => 'authentications#create'
  mount StripeEvent::Engine => '/stripe'
  devise_for :users, :path_names => { :sign_up => "register", :sign_in => "login", :sign_out => "logout", :skip => [:registrations]},:sign_out_via => ["DELETE","GET"], :controllers => {:registrations => 'registrations' ,omniauth_callbacks: "authentications" }
  root :to => 'home#index'
  match '/list/:id' => 'Lists#show', :as => :list_view
  match '/list/create' => 'Lists#create' , :as =>  :create_list
  #match "lists/:list_id/tasks" => "tasks#create"
  match '/tasks/sort', :controller => 'tasks', :action => 'sort', :as => 'sort_tasks'
  resources :lists do
    resources :tasks
  end
  
  get 'content/member'
  get 'content/vipmember'
  match '/signup_options' => 'home#signup_options' , :as => :signup_options
  match 'lists/:list_id/tasks/:id/complete' => 'tasks#complete', :as => :complete_task
  match 'lists/:list_id/tasks/:id/incomplete' => 'tasks#incomplete', :as => :incomplete_task
  match 'lists/:list_id/tasks/:id/edit' => "tasks#edit" , :as => :edit_task
  match 'lists/:list_id/tasks/:id/delete' => "tasks#delete" , :as => :delete_task
  match 'lists/:list_id/tasks/:id/hasduedate' => 'tasks#hasduedate' , :as => :has_due_date
  match 'lists/:list_id/tasks/:id/noduedate' => 'tasks#noduedate' , :as => :no_due_date
  match 'litss/:list_id/tasks/:id/update_due_date' => 'tasks#update_due_date' , :as => :update_due_date
  match 'my-list' => "Lists#mylist" , :as => :my_list
  match 'invite/:id' => "MyConnection#invite_connect" , :as => :invite_connect
  match 'create_invite_connect/:id' => "MyConnection#create_invite_connect" , :as => :create_invite_connect
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
    match '/signup_member' => 'registrations#member' , :as => :member_registration
    match '/signup_paid_member' => 'registrations#paid' , :as => :paid_registration
  end
  resources :users
end
