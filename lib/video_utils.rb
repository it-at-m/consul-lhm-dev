module VideoUtils
  YOUTUBE_PLATFORM = :youtube
  VIMEO_PLATFORM = :vimeo

  VideoInfo = Struct.new(:external_id, :platform, keyword_init: true)

  def self.extract_info(url)
    platform = extract_video_platform_from_url(url)
    external_id = extract_video_id_from_url(url, platform)

    VideoInfo.new(platform: platform, external_id: external_id)
  end

  def self.extract_video_platform_from_url(url)
    if url.include?("youtube.")
      YOUTUBE_PLATFORM
    elsif url.include?("vimeo.")
      VIMEO_PLATFORM
    end
  end

  def self.extract_video_id_from_url(url, platform)
    case platform
    when YOUTUBE_PLATFORM
      url.match(/v\=(?<youtube_id>\w+)/)[:youtube_id]
    when VIMEO_PLATFORM
      url.match(/vimeo\.com\/(?<vimeo_id>\w+)/)[:vimeo_id]
    end
  end

  def self.embed_url(platform:, external_id:)
    case platform
    when YOUTUBE_PLATFORM
      "https://www.youtube.com/embed/#{external_id}"
    when VIMEO_PLATFORM
      "https://player.vimeo.com/video/#{external_id}"
    end
  end

  def self.embed_url_for_video_url(url)
    video_info = extract_info(url)

    embed_url(
      platform: video_info.platform,
      external_id: video_info.external_id
    )
  end
end
