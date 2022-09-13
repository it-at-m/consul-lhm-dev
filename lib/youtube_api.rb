class YoutubeApi
  include HTTParty

  base_uri "https://www.googleapis.com/youtube/v3"

  VIDEO_FILEDS = "snippet,contentDetails,statistics,status,liveStreamingDetails".freeze

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_video(video_id)
    response = self.class.get("/videos", query: { id: video_id, key: @api_key, part: VIDEO_FILEDS })

    if response.success? && response.body.present?
      JSON.parse(response.body)['items'].first
    end
  end
end
