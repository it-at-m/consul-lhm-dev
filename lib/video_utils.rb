module VideoUtils
  YOUTUBE_PLATFORM = 'youtube'
  VIMEO_PLATFORM = 'vimeo'

  VideoInfo = Struct.new(:external_id, :platform, keyword_init: true)

  def self.extract_info(url)
    platform =
      if url.include?("youtube.")
        YOUTUBE_PLATFORM
      elsif url.include?("vimeo.")
        VIMEO_PLATFORM
      end

    external_id =
      case platform
      when YOUTUBE_PLATFORM
        url.match(/v\=(?<youtube_id>\w+)/)[:youtube_id]
      when VIMEO_PLATFORM
        url.match(/vimeo\.com\/(?<vimeo_id>\w+)/)[:vimeo_id]
      end

    VideoInfo.new(platform: platform, external_id: external_id)
  end

  def self.embed_url(url)
    video_info = extract_info(url)

    case video_info.platform
    when YOUTUBE_PLATFORM
      "https://www.youtube.com/embed/#{video_info.external_id}"
    when VIMEO_PLATFORM
      "https://player.vimeo.com/video/#{video_info.external_id}"
    end
  end
end
