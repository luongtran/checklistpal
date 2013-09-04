Checklistpal::Application.routes.draw do
  #match '*path', :to => 'static_pages#not_found'

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
                              :omniauth_callbacks => "omniauth_callbacks",
                              :sessions => "sessions",
                              :invitations => 'users/invitations',
                              :passwords => "passwords"
             }
  root :to => 'home#index'
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
  get '/pdf_version' => 'lists#pdf', :as => :pdf_version
  match '/signup_options' => 'home#signup_options', :as => :signup_options
  match 'lists/:list_id/tasks/:id/complete' => 'tasks#complete', :as => :complete_task
  match 'lists/:list_id/tasks/:id/edit' => "tasks#edit", :as => :edit_task
  match 'lists/:id/edit' => "lists#edit", :as => :edit_list
  match 'lists/:list_id/tasks/:id/delete' => "tasks#delete", :as => :delete_task
  match 'lists/:list_id/tasks/:id/hasduedate' => "tasks#hasduedate", :as => :has_due_date
  match 'lists/:list_id/tasks/:id/update_due_date' => 'tasks#update_due_date', :as => :update_due_date
  match 'mylists' => "lists#mylist", :as => :my_list
  match 'create_new_list' => "home#index", :as => :create_new_list
  match 'remove_connect/:list_id/:user_id' => 'lists#remove_connect', :as => :remove_connect
  match 'mylists/:id/delete' => "lists#destroy", :as => :delete_list

  match '/invite_user/:list_id' => 'home#find_invite', :as => :find_invite
  match '/invite/:list_id' => 'home#invite', :as => :invite
  match '/invite_user_by_email' => 'home#invite_user_by_email', :as => :invite_user_by_email
  match '/find_users_for_invite' => "home#find_users_for_invite", :as => :find_users_for_invite
  match '/home/find_and_invite' => 'home#find_and_invite', :as => :find_and_invite

  match 'task/:task_id/comment/create' => "comments#create", :as => :add_comment
  match '/lists/:list_id/task/:id/show' => "tasks#show", :as => :view_task
  match '/mylists/search' => 'lists#search_my_list', :as => :search_my_list

  match '/mylists/see_more_my_list' => 'lists#see_more_my_list'
  match '/mylists/see_more_archived_list' => 'lists#see_more_archived_list'
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
