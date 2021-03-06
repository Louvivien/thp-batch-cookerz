Rails.application.routes.draw do
  
  devise_for :users
  
  root 'home#index'
  get 'contact', to: 'single_pages#contact'
  get 'concept', to: 'single_pages#concept'
  get 'team', to: 'single_pages#team'
  
 

  resources :ingredients, only: [:index] 
  resources :menu_recipes, only: [:create, :destroy] do 
    get :autocomplete_recipe_name, :on => :collection
  end

  resources :recipes, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    get :autocomplete_ingredient_name, :on => :collection
    resources :comments, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
    resources :pictures, only: [:create, :show]
  end
  
  resources :users, only: [:show, :edit, :update, :destroy] do
    resources :avatars, only: [:create]
    resources :menus, only: [:show, :destroy, :update] do 
      resources :shopping_lists, only: [:show,:create]
    end
  end

  resources :recipe_categories, only: [:show] 

  namespace :admin do 
    resources :recipes, only: [:index, :edit, :update, :destroy]
    resources :users, only: [:index, :edit, :update, :destroy]
    resources :comments, only: [:destroy]
  end
  
end


