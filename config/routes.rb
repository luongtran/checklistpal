Checklistpal::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  match '/auth/:provider/callback' => 'authentications#create'
  mount StripeEvent::Engine => '/stripe'

  devise_for :users, :path_names => {:sign_up => "register",
                                     :sign_in => "login",
                                     :sign_out => "logout",
                                     :skip => [:registrations]},
             :sign_out_via => ["DELETE", "GET"],
             :controllers => {:registrations => 'registrations',
                              :omniauth_callbacks => "authentications",
                              sessions: "sessions",
                              :invitations => 'users/invitations'
             }
  # devise_for :users, controllers: {sessions: "sessions"}

  ActiveAdmin.routes(self)
  root :to => 'home#index'

  #match 'list/public' => 'lists/new', :as => :create_new_list

  match '/tasks/sort', :controller => 'tasks', :action => 'sort', :as => 'sort_tasks'
  get 'lists/download_pdf' => 'lists#download_pdf', :as => :download_pdf
  get '/lists/:slug' => 'Lists#show', :as => :list_view
  get '/inviting' => 'home#inviting', :as => :inviting
  get '/dashboard' => 'home#dashboard', :as => :dashboard
  post '/users/feedback'
  post '/users/upload_avatar'
  resources :lists do
    resources :tasks
  end
  resources :tasks do
    resources :comments
  end
  match '/signup_options' => 'home#signup_options', :as => :signup_options
  match 'lists/:list_id/tasks/:id/complete' => 'tasks#complete', :as => :complete_task
  match 'lists/:list_id/tasks/:id/edit' => "tasks#edit", :as => :edit_task
  match 'lists/:id/edit' => "lists#edit", :as => :edit_list
  match 'lists/:list_id/tasks/:id/delete' => "tasks#delete", :as => :delete_task
  match 'lists/:list_id/tasks/:id/hasduedate' => "tasks#hasduedate", :as => :has_due_date
  match 'lists/:list_id/tasks/:id/update_due_date' => 'tasks#update_due_date', :as => :update_due_date
  match 'mylists' => "lists#mylist", :as => :my_list
  match 'remove_connect/:list_id/:user_id' => 'lists#remove_connect', :as => :remove_connect
  match 'who_connection/:id' => "lists#who_connection", :as => :who_connect
  match 'mylists/:id/delete' => "lists#destroy", :as => :delete_list
  match '/invite_user/:list_id' => 'home#find_invite', :as => :find_invite

  match '/find_multi_invite' => 'home#find_multi_invite', :as => :find_invite_multi
  match '/pass_parametter' => 'home#pass_parametter', :as => :pass_parametter


  match '/invite/:list_id' => 'home#invite', :as => :invite

  match '/home/find_and_invite' => 'home#find_and_invite', :as => :find_and_invite

  match '/invite_multi' => 'home#invite_multi', :as => :invitation_multi


  match 'invite/(:list_id)/user' => "home#invite_user_by_id", :as => :invite_user
  match '/inviteuser' => 'home#invite_user_by_id_multi_list', :as => :invite_user_multi
  match 'task/:task_id/comment/create' => "comments#create", :as => :add_comment
  match '/lists/:list_id/task/:id/show' => "tasks#show", :as => :view_task
  match '/mylists/search' => 'lists#search_my_list', :as => :search_my_list
  match '/search_my_connect' => 'home#search_my_connect', :as => :search_my_connect
  match '/about' => 'static_pages#about', :as => :about
  match '/support' => 'static_pages#support', :as => :support
  match '/psupport' => 'static_pages#paid_support', :as => :paid_support

  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'

    get 'my_account', :to => 'devise/registrations#edit', :as => :my_account
  end
  match '/404', :to => 'static_pages#not_found'
  match '/500', :to => 'static_pages#server_error'
end
