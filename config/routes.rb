DataQualityManager::Application.routes.draw do

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # ---------- Namespace: Scheduler
  namespace :scheduler do
    resources :production_jobs do
      resources :production_schedules
    end
    resources :production_groups do
      member do
        post :trigger
        get :analyse
        get :get_children    # remote request used for navigation menu
      end
    end
    resources :production_events do
      member do
        post :trigger
        get :analyse
      end
    end
    resources :production_schedules do
      member do
        post :run_once
        get :suspend
        get :release
      end
    end
    resources :production_executions do
      member do
        post :execute
        get :analyse
        get :get_children    # remote request used for navigation menu
      end
    end
  end

  # ---------- Namespace: Sidekiq
  require 'sidekiq/web'
  #require 'sidekiq-scheduler/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  # ---------- Namespace: Governance
  namespace :governance do
    get 'monitoring',      to: "/governance/monitoring_pages#metadata"

    resources :notifications do
      member do
        get :reopen
      end
    end

    resources :audit_trails, :path => "logs", :only=>[:index] #, :controller=>:audit_trails
  end

  # ---------- Namespace: Administration
  namespace :administration do
    get 'users',           to: "/administration/users#index"
    get 'data_imports',    to: "/administration/data_imports#new"

    resources :users do
      member do
        patch :set_playground
        #get :pass
        post :activate
      end
      collection do
        get :export
        post :set_external_reference
      end
    end

    resources :groups do
      member do
        post :activate
      end
    end

    resources :parameters_lists do
      resources :parameters
      resources :parameters_imports, :only=>[:new, :create]
       member do
         post :activate
       end
    end

    resources :parameters

    resources :data_imports

    resources :territories do
       resources :territories, :only=>[:new, :create]
       member do
         post :activate
       end
    end

    resources :organisations do
       resources :organisations, :only=>[:new, :create]
       member do
         post :activate
       end
    end

  end
  # ---------- End of Namespaces

  # devise routes
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, :skip => [:registrations]
    as :user do
      get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
      put 'users' => 'devise/registrations#update', :as => 'user_registration'
    end
  resources :requests

#static pages
  get 'help/*page_name', :controller => 'help', :action => 'help', :as => :help
  get '/credits', 	to: "static_pages#credits"
#  get '/about', 	to: "static_pages#about"
#  get '/contact', 	to: "static_pages#contact"
  get '/monitoring',      to: "monitoring_pages#metadata"
# get '/scheduler/home',  to: "scheduler/static_pages#home"
  get '/wpad.dat',    to: "static_pages#wpad.dat"
  match '/API/external_user_directory', to: "administration/users#set_external_reference", via: :post
  match '/API/external_organisations',  to: "organisations#set_external_reference", via: :post
  match '/API/external_domains',        to: "business_areas#set_external_reference", via: :post
  match '/API/external_activities',     to: "business_flows#set_external_reference", via: :post
### Christian Stadler specific
  get '/dsd', to: redirect('/html/sis-sms-tools/Dynamic_DSD/index.html')
  get '/dashboard', to: redirect('/html/sis-sms-tools/SIS_Dashboard/v4_test.html')

#root definition
  root to: "playgrounds#index"


#routes

#session management
  #resources :sessions, only: [:new, :create, :destroy]
  #get '/signin',  to: 'sessions#new'	, via: :get
  #match '/signout', to: 'sessions#destroy', via: :delete

#data importation features
resources :business_hierarchy_imports, :only=>[:new, :create]
resources :users_imports, :only=>[:new, :create]
resources :parameters_lists_imports, :only=>[:new, :create]
resources :business_objects_imports, :only=>[:new, :create]
resources :business_rules_imports, :only=>[:new, :create]
resources :tasks_imports, :only=>[:new, :create]
resources :territories_imports, :only=>[:new, :create]
resources :organisations_imports, :only=>[:new, :create]
resources :data_imports, :only=>[:new, :create]

#search in translations
#get '/search',  to: 'translations#index'	, via: :get
resources :translations, :only=>[:index]

#business objects management
  resources :business_areas, :path => "information_domains"  do
    resources :business_flows, :only=>[:new, :create]
    resources :defined_objects, :only=>[:new, :create]
    resources :values_lists, :only=>[:new, :create]
    resources :classifications, :only=>[:new, :create]
    member do
      post :activate
      get :get_children    # remote request used for navigation menu
    end
  end

  resources :business_flows, :path => "statistical_activities" do
    resources :business_processes, :only=>[:new, :create]
    member do
      post :activate
      get :get_children    # remote request used for navigation menu
    end
  end

  resources :business_processes, :path => "scheduler_flows" do
    resources :business_rules, :only=>[:new, :create]
    resources :deployed_objects, :only=>[:new, :create, :derive] do
      member do
        #post :derive
      end
    end
    resources :activities, :only=>[:new, :create]
    member do
      post :activate
      get  :schedule
    end
  end

  resources :defined_objects, :path => "defined_metadata" do
    resources :defined_skills                   # Properties of a business object
    resources :skills_imports, :only=>[:new, :create]
    resources :business_rules
    resources :scopes
    member do
      post :new_version
      post :make_current
      post :finalise
      post :activate
      get  :read_SDMX
    end
  end

  resources :deployed_objects, :path => "deployed_metadata", :controller => "deployed_objects" do
    resources :deployed_skills                   # Properties of a business object
    resources :skills_imports, :only=>[:new, :create]
    resources :business_rules
    resources :scopes
    member do
      get  :script
      get  :export
      post :new_version
      post :make_current
      post :finalise
      post :activate
      post :derive
      post :propose
      post :accept
      post :reject
      post :reopen
      get :var_update
      post :open_cart     # Declares that the current business object collects skills as a cart
      post :close_cart    # Unsets the current business as cart
    end
  end

  resources :defined_skills, :path => "defined_variables" do
    resources :values_lists
    member do
      post :add_to_cart
      get  :create_values_list
      get  :upload_values_list
      get  :remove_values_list
      post :propose
      post :accept
      post :reject
      post :reopen
      post :activate
    end
    collection do
      get :list
    end
  end


  resources :deployed_skills, :path => "used_variables" do
    resources :values_lists
    member do
      post :add_to_cart
      get  :create_values_list
      get  :upload_values_list
      get  :remove_values_list
    end
  end

  resources :activities, :path => "subprocess" do
    resources :tasks
    member do
      post :activate
      get  :get_children

    end
  end

  resources :business_rules, :path => "plausibilisation" do
    resources :breaches
    resources :tasks
    member do
      post :new_version
      post :make_current
      post :finalise
      post :activate
      post :propose
      post :accept
      post :reject
      post :reopen

      post :release
      post :push_migration

    end
  end

  resources :business_hierarchies, :only=>[:index, :new, :create, :load, :unload] do
    collection do
      post :load
      post :unload
      post :export
    end
    member do
    end
  end

#project structure
  resources :scopes, :path => "datasets" do
    resources :business_rules, :only=>[:new, :create]
    member do
      post :new_version
      post :make_current
      post :finalise
      post :activate
    end
  end

  resources :landscapes do
    resources :scopes, :only=>[:new, :create]
    member do
      post :activate
    end
  end

  resources :playgrounds, :path => "statistical_themes" do
    resources :landscapes, :only=>[:new, :create]
    resources :business_areas, :only=>[:new, :create]
    member do
      post :activate
      patch :set_as_current
      get :get_children    # remote request used for navigation menu
    end
  end

#other artefacts

  resources :values, :path => "codes" do
    member do
      get :child_values
      get :child_values_count
      get :get_children
    end
  end

  resources :values_lists, :path => "code_lists" do
    resources :values #, :only=>[:new, :show, :edit, :destroy]
    resources :values_imports, :only=>[:new, :create]
    member do
      post :new_version
      post :make_current
      post :finalise
      post :activate
      post :propose
      post :accept
      post :reject
      post :reopen
      get :extract
      get :get_children
      get :read_SDMX
    end
  end

  resources :classifications, :path => "value-sets" do
  resources :classification_links_imports, :only=>[:new, :create]
      member do
        post :new_version
        post :make_current
        post :finalise
        post :activate
        post :propose
        post :accept
        post :reject
        post :reopen
        get :extract
      end
  end

  resources :breaches


  resources :records do
    resources :update_requests, :only=>[:new, :create]
  end

  resources :time_scales

  resources :data_policies do
    member do
      post :finalise
      get :links
    end
  end

  resources :tasks do
    member do
      post :verify
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
