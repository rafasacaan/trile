Rails.application.routes.draw do
  resources :circuits do
      get 'data_tool', on: :collection, as: :"data-tool"
    end

  resources :demands, controller: 'circuits', type: 'Demand'
  resources :generations, controller: 'circuits', type: 'Generation' 
  devise_for :users
  resources :users, only: :show
  
  get 'welcome/index'
  root 'welcome#index'

  #Rutas para las llamadas ajax
  get  'reports/today_measures/:id', to: 'reports#today_measures'
  get  'reports/week_measures/:id', to: 'reports#week_measures'
  get  'reports/month_measures/:id', to: 'reports#month_measures'
  get  'reports/year_measures/:id', to: 'reports#year_measures'
  get  'reports/circuit_type/:id', to: 'reports#circuit_type'
  get  'reports/specific_date_measures/:id/:date', to: 'reports#specific_date_measures'
  get  'reports/index_measures/', to: 'reports#index_measures'
  get  'reports/labels/', to: 'reports#labels'
  get  'reports/welcome_index/', to: 'reports#welcome_index'
  get  'reports/last_five/:id', to: 'reports#last_five'


#rutas para la API
  namespace :api, path: '/', constraints: { subdomain: 'api' } do
    resources :circuits do
      resources :measures
    end
  end
end

