Rails.application.routes.draw do
  resources :calls, only: :index do
    collection do
      post :webhook
      post :status
      post :error
      post :voicemail
    end
  end

  root to: 'calls#index'
end
