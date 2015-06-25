Rails.application.routes.draw do
  resources :circuits
  resources :demands, controller: 'circuits', type: 'Demand'
  resources :generations, controller: 'circuits', type: 'Generation' 
  devise_for :users
  resources :users, only: :show
  get 'welcome/index'
  get 'welcome/general'
  get 'welcome/buttons'
  get 'welcome/panels'
  get 'welcome/calendar'
  get 'index' => "welcome#index"
  root 'welcome#index'

  get  'reports/today_measures/:id', to: 'reports#today_measures'
  get  'reports/week_measures/:id', to: 'reports#week_measures'
  get  'reports/month_measures/:id', to: 'reports#month_measures'
  get  'reports/year_measures/:id', to: 'reports#year_measures'
  get  'reports/circuit_type/:id', to: 'reports#circuit_type'
  get  'reports/specific_date_measures/:id/:date', to: 'reports#specific_date_measures'
  get  'reports/index_measures/', to: 'reports#index_measures'

  namespace :api, path: '/', constraints: { subdomain: 'api' } do
    resources :circuits do
      resources :measures
    end
  end
end

