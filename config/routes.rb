Rails.application.routes.draw do

  root to: 'welcome#home'

  scope "/api" do
    resources :tasks
    resources :workers
  end

  get '*other', to: 'welcome#home'
end
