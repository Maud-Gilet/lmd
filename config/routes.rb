Rails.application.routes.draw do
  devise_for :users, :controllers => { :invitations => 'users/invitations' }

  authenticated :user do
    root 'pages#home'
  end

  root 'pages#landing'


  resources :companies do
    resources :captables, only: [:show, :new, :create]
    post 'new_nominal', to: 'companies#create_nominal', as: 'create_nominal'


    resources :operations, only: [:index, :new, :create] do
      resources :investors, only: [:index, :new, :create]
      resources :investments, only: [:index, :new, :create]
    end
  end


  resources :operations, only: :show do
    member do
      post "create_documents", to: "d_documents#create_documents"
      # post "/operations/:id/create_documents", to: "d_documents#create_documents"
    end
    resources :d_documents, only: [:index] do
      get "sign_documents", to: "d_documents#sign_documents"
    end

    resources :s_documents, only: [:index, :show, :new, :create, :destroy]
  end

  resources :d_documents, only: :show
  resources :investments, only: [:show, :edit, :update, :destroy] do
    member do
      patch 'confirm_invest', to: 'investments#confirm_invest'
    end
  end

  resources :roles

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
