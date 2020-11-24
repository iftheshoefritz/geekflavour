class LanguageJob < ApplicationJob
  include CableReady::Broadcaster

  sidekiq_options retry: 0
  queue_as :default

  def perform(callback_code, session_id) # consider passing username
    @session_id = session_id
    status_update "Obtaining access token from Github..."
    response = RestClient.post(
      'https://github.com/login/oauth/access_token',
      {
        :client_id => client_id,
        :client_secret => client_secret,
        :code => callback_code
      },
      accept: :json
    )

    access_token = JSON.parse(response)['access_token']
    client = Octokit::Client.new(access_token: access_token)
    status_update "fetching User repos..."
    repos = client.user[:repos_url]
    project_languages_urls = client.get(repos).map(&:languages_url)
    top_languages_per_repo = project_languages_urls.each_with_object([]) do |url, memo|
      project = url.split("/").last(2).join("/")
      status_update "fetching #{project}"
      memo << client.get(url).sort_by { |_language, lines| lines }.last&.first
    end
    status_update "Counting use of languages in your repos..."
    top_languages_count = top_languages_per_repo.each_with_object(Hash.new(0)) { |lg, result| result[lg] += 1 }
    top_language = top_languages_count.max_by { |_lg, count| count }.first
    status_update "Top language: " + top_language.to_s
  end

  def client_id
    Rails.application.credentials.github[:client_id]
  end

  def client_secret
    Rails.application.credentials.github[:secret]
  end

  def status_update(msg)
    puts "[#{self.job_id}] #{msg}"
    cable_ready["progress-stream-#{@session_id}"].inner_html(
      selector: '#content',
      html: "[#{self.job_id}] #{msg}"
    )
    cable_ready.broadcast
  end


end
