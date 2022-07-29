class Shared::ExternalVideoPlayer < ApplicationComponent
  def initialize(external_video_id:, video_platform:, width: nil, height: nil)
    @external_video_id = external_video_id
    @video_platform = video_platform
    @width = width
    @height = height
  end

  def youtube_video?
    @video_platform == "youtube"
  end

  def vimeo_video?
    @video_platform == "vimeo"
  end

  def youtube_video_src
    "https://www.youtube.com/embed/#{@external_video_id}"
  end

  def vimeo_video_src
    "https://player.vimeo.com/video/#{@external_video_id}?h=bf7ab47f2b"
  end

  def video_width
    @width.presence || 560
  end

  def video_height
    if youtube_video?
      (video_width / 1.5).round
    elsif vimeo_video?
      (video_width / 1.7).round
    end
  end
end
