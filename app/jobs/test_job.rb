class TestJob < ApplicationJob
  include CableReady::Broadcaster
  queue_as :default

  def perform(*args)
    puts "*"*50 + "running job! Sending transform from progress-stream"
    cable_ready['progress-stream'].inner_html(
      selector: '#content',
      html: 'Hello World this is the background job.'
    )
    cable_ready.broadcast
  end
end
