Rails.application.routes.draw do
  root 'welcome#index'
  get '/callback', to: 'welcome#callback'
end
