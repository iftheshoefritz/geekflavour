Rails.application.routes.draw do
  root 'welcome#index'
  get '/github2', to:  'welcome#github2'
  get '/callback', to: 'welcome#callback'
end
