Rails.application.routes.draw do

  mount Qa::Engine => '/qa'

  root 'login#index'

  # Create multiple routes,
  resources :entries
  resources :concepts
  resources :places
  resources :people
  resources :subjects
  resources :errors

  # Create single routes
  get 'image_zoom_large' => 'image_zoom_large#index'
  get 'logout' => 'login#logout'
  get 'login' => 'login#index'
  get 'login_submit' => 'login#login_submit'
  get 'login_temp' => 'login#login_temp'
  get 'timed_out' => 'login#timed_out'
  get 'landing_page' => 'landing_page#index'
  get 'browse_folios' => 'browse_folios#index'
  get 'go_entries' => 'landing_page#go_entries'
  get 'admins' => 'admins#index'

  get "/404" => "errors#not_found"
  get "/500" => "errors#internal_server_error"

  #root :to => "catalog#login"
  #blacklight_for :catalog
  #devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#login'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
