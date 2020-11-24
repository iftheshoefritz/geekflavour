class LanguageJob < ApplicationJob
  include CableReady::Broadcaster

  sidekiq_options retry: 0
  queue_as :default

  def perform(callback_code, session_id) # consider passing username
    begin
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
        begin
          project = url.split("/").last(2).join("/")
          status_update "fetching #{project}"
          memo << client.get(url).sort_by { |_language, lines| lines }.last&.first
        rescue Octokit::Error => e
          Rails.logger.error("Error fetching info at project URL #{url}")
          log_error(e)
        end
      end
      status_update "Counting use of languages in your repos..."
      top_languages_count = top_languages_per_repo.each_with_object(Hash.new(0)) { |lg, result| result[lg] += 1 }
      top_language = top_languages_count.max_by { |_lg, count| count }.first
      answer_update(top_language.to_s)

    rescue StandardError => e
      status_update("Ack! Error fetching from github: #{e.message}")
      log_error(e)
    end
  end

  def client_id
    Rails.application.credentials.github[:client_id]
  end

  def client_secret
    Rails.application.credentials.github[:secret]
  end

  def status_update(msg)
    Rails.logger.info("[#{self.job_id}] #{msg}")
    cable_ready["progress-stream-#{@session_id}"].inner_html(
      selector: '#content',
      html: msg
    )
    cable_ready.broadcast
  end

  def answer_update(msg)
    Rails.logger.info("[#{self.job_id}] #{msg}")
    cable_ready["progress-stream-#{@session_id}"].inner_html(
      selector: '#content',
      html: ''
    )
    cable_ready.broadcast
    cable_ready["progress-stream-#{@session_id}"].inner_html(
      selector: '#answer',
      html: msg
    )
    cable_ready.broadcast
    cable_ready["progress-stream-#{@session_id}"].inner_html(
      selector: '#language',
      html: msg
    )
    cable_ready.broadcast
  end

  def log_error(error)
    Rails.logger.error [error.message, *error.backtrace].join($/)
  end
end
