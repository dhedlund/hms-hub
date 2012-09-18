HmsHub::Application.routes.draw do
  namespace :api do
    get 'test/ping' => :ping
    resources :message_streams, :path => :streams, :only => [:index]

    resources :notifications, :only => [:create] do
      get :updated, :on => :collection
    end
  end

  namespace :admin do
    get '/' => :index
    resources :delivery_attempts, :only => [:index, :show] do
      collection do
        resources :phone, :to => "delivery_attempts#phone",:only => [:show], :on => :member,
          :as => 'delivery_attempts_phone'
        resources :search, :to => "delivery_attempts#search",:only => [:index], :on => :member,
          :as => 'delivery_attempts_search'
      end
    end
    resources :message_streams, :path => :streams, :only => [:index, :show] do
      resources :messages, :only => [:index, :show]
    end
    resources :messages, :only => [:index, :show]
    resources :notifications, :except => [:destroy] do
      collection do
        resources :phone, :to => "notifications#phone",:only => [:show], :on => :member,
          :as => 'notifications_phone'
        resources :search, :to => "notifications#search",:only => [:index], :on => :member,
          :as => 'notifications_search'
      end
    end
    resources :notifiers, :except => [:destroy]
    resources :jobs, :only => [:index, :show]
    resources :users, :only => [:index, :show]
    resources :reports, :only => [:index] do
      collection do
        resources :download, :to => "reports#download", :only => [:show], :on => :member,
          :as => 'reports_download'
      end
    end
  end

  match 'api/*url' => 'api#not_found'

  get 'nexmo/confirmation' => 'nexmo#confirm_delivery'
  get 'nexmo/inbound_sms' => 'nexmo#accept_delivery'

  post 'intellivr/confirmation' => 'intellivr#confirm_delivery'

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
