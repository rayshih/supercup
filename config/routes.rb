Rails.application.routes.draw do
  root to: 'welcome#home'

  resources 'tasks'
  get '*other', to: 'welcome#home'
end
