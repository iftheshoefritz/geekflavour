class WelcomeController < ApplicationController
  def index
    TestJob.set(wait: 5.seconds).perform_later
  end

end
