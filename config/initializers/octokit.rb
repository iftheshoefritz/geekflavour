stack = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::Request::Retry, exceptions: [Octokit::ServerError]
  builder.use Octokit::Middleware::FollowRedirects
  builder.use Octokit::Response::RaiseError
  builder.use Octokit::Response::FeedParser
  builder.response :logger
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
