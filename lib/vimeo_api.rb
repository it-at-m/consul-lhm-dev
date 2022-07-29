class VimeoApi
  include HTTParty

  base_uri "https://vimeo.com/api/"

  def fetch_video(video_url)
    JSON.parse(self.class.get("/oembed.json?url=#{video_url}").body)
  end
end
