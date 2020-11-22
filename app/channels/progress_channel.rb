class ProgressChannel < ApplicationCable::Channel
  def subscribed
    puts "*"*75 + 'subscribed ProgressChannel'
    puts "*"*75 + 'ProgressChannel stream_from progress-stream'
    stream_from 'progress-stream'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
