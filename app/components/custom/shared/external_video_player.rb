class Shared::ExternalVideoPlayer < ApplicationComponent
  def initialize(external_video_id: nil, video_platform: nil, width: nil, height: nil, url: nil)
    # @external_video_id = external_video_id
    # @video_platform = video_platform
    @url = url
    @width = width
    @height = height
  end

  def youtube_video?
    @url =~ /youtu*.*/
  end

  def vimeo_video?
    @url =~ /vimeo.*/
  end

  def allow_attribute
    if youtube_video?
      "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    elsif vimeo_video?
      "autoplay; fullscreen; picture-in-picture"
    end
  end
end
