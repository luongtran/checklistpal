Checklistpal::Application.routes.draw do
  match '/auth/:provider/callback' => 'authentications#create'
  mount StripeEvent::Engine => '/stripe'
  devise_for :users, :path_names => { :sign_up => "register", :sign_in => "login", :sign_out => "logout", :skip => [:registrations]},:sign_out_via => ["DELETE","GET"], :controllers => {:registrations => 'registrations' ,omniauth_callbacks: "authentications",:invitations => 'users/invitations' }
  root :to => 'home#index'

  #get 'lists/:id', to: 'Lists#show', constraints: {id: /^\d/}
  #match '/lists/create' => 'Lists#create' , :as =>  :create_list
  #match "lists/:list_id/tasks" => "tasks#create"
  match '/tasks/sort', :controller => 'tasks', :action => 'sort', :as => 'sort_tasks'
  resources :lists do
    resources :tasks 
  end
  resources :tasks do
      resources :comments
    end
  get 'content/member'
  get 'content/vipmember'
  get '/lists/:id' => 'Lists#show', :as => :list_view
  match '/signup_options' => 'home#signup_options' , :as => :signup_options
  match 'lists/:list_id/tasks/:id/complete' => 'tasks#complete', :as => :complete_task
  match 'lists/:list_id/tasks/:id/edit' => "tasks#edit" , :as => :edit_task
  match 'lists/:id/edit' => "lists#edit" , :as => :edit_list
  match 'lists/:list_id/tasks/:id/delete' => "tasks#delete" , :as => :delete_task
  match 'lists/:list_id/tasks/:id/hasduedate' => "tasks#hasduedate" , :as => :has_due_date
  match 'lists/:list_id/tasks/:id/update_due_date' => 'tasks#update_due_date' , :as => :update_due_date
  match 'mylist' => "lists#mylist" , :as => :my_list
  match 'who_connection/:id' => "lists#who_connection" , :as => :who_connect
  match 'mylist/:id/delete' => "lists#destroy" , :as => :delete_list
  #match 'list/:list_id/invite-user' => 'lists#invite_user', :as => :invite_user
  match '/invite_user/:list_id' => 'home#find_invite' ,:as => :find_invite
  match '/invite/:list_id' => 'home#invite' ,:as => :invite
  match 'invite/(:list_id)/user' => "home#invite_user_by_id", :as => :invite_user
  match 'task/:task_id/comment/create' => "comments#create" , :as => :add_comment
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
  end
  resources :users
end
