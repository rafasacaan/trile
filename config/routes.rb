Rails.application.routes.draw do
  get 'infographics/index'

  resources :circuits, except: :destroy
  resources :demands, controller: 'circuits', type: 'Demand', except: :destroy
  resources :generations, controller: 'circuits', type: 'Generation', except: :destroy 
  devise_for :users, skip: :registrations
  devise_scope :user do
  resource :registration,
    only: [:new, :create, :edit, :update],
    path: 'users',
    path_names: { new: 'sign_up' },
    controller: 'devise/registrations',
    as: :user_registration do
      get :cancel
      end
  end
  
  resources :users, only: :show
  
  get 'welcome/index'
  root 'welcome#index'

  #Endpoints for graphs
  get  'reports/today_measures/:id/:date', to: 'reports#today_measures'
  get  'reports/week_measures/:id/:date', to: 'reports#week_measures'
  get  'reports/month_measures/:id/:date', to: 'reports#month_measures'
  get  'reports/year_measures/:id/:date', to: 'reports#year_measures'
  get  'reports/circuit_type/:id', to: 'reports#circuit_type'
  get  'reports/specific_date_measures/:id/:date', to: 'reports#specific_date_measures'
  get  'reports/labels/', to: 'reports#labels'
  get  'reports/welcome_index/', to: 'reports#welcome_index'
  get  'reports/last_five/:id', to: 'reports#last_five'
  get  'reports/donuts/:date/:type', to: 'reports#donuts'


#API endpoints
  namespace :api, path: '/', constraints: { subdomain: 'api' } do
    resources :circuits do
      resources :measures
    end
  end
end

