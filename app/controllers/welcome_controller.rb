class WelcomeController < ApplicationController
  before_action do
    @token = request.session.id
  end

  def index
    TestJob.set(wait: 5.seconds).perform_later
  end

  def github2
    @client_id = client_id
  end

  def callback
    @sesh = request.session.id # TODO: remove
    LanguageJob.perform_later(params[:code], @token.to_s)
  end

  def client_id
    Rails.application.credentials.github[:client_id]
  end
end
