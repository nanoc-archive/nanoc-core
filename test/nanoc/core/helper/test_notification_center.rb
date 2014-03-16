# encoding: utf-8

class Nanoc::NotificationCenterTest < Nanoc::TestCase

  def test_post
    # Set up notification
    Nanoc::NotificationCenter.on :ping_received, :test do
      @ping_received = true
    end

    # Post
    @ping_received = false
    Nanoc::NotificationCenter.post :ping_received
    assert(@ping_received)
  end

  def test_remove
    # Set up notification
    data = {}
    Nanoc::NotificationCenter.on :data_available, :test do |data, value|
      data[:value] = value
    end

    # Post once
    Nanoc::NotificationCenter.post :data_available, data, 111
    assert(data[:value] = 111)

    # Remove observer
    Nanoc::NotificationCenter.remove :data_available, :test

    # Post again
    Nanoc::NotificationCenter.post :data_available, data, 222
    assert(data[:value] = 111)
  end

end
