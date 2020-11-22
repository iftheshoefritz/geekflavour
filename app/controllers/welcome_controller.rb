class WelcomeController < ApplicationController
  def index
    TestJob.set(wait: 5.seconds).perform_later
  end

  def github2
    @client_id = client_id
  end

  def callback
    LanguageJob.perform_later(params[:code])
  end

  def client_id
    Rails.application.credentials.github[:client_id]
  end
end
