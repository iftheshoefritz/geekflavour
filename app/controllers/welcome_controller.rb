class WelcomeController < ApplicationController
  before_action do
    @token = request.session.id.to_s
  end

  def index
    @client_id = client_id
  end

  def callback
    LanguageJob.perform_later(params[:code], @token)
  end

  def client_id
    Rails.application.credentials.github[:client_id]
  end
end
