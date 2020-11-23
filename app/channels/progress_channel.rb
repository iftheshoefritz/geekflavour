class ProgressChannel < ApplicationCable::Channel
  def subscribed
    stream_from "progress-stream-#{params[:token]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
