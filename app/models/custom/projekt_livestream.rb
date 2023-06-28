class ProjektLivestream < ApplicationRecord
  belongs_to :old_projekt, class_name: "Projekt", foreign_key: "projekt_id" # TODO: remove column after data migration con1538

  delegate :projekt, to: :projekt_phase
  belongs_to :projekt_phase

  validates :url, presence: true

  default_scope { order(starts_at: :desc) }

  before_save :assign_video_platform
  before_save :assign_external_id
  before_save :strip_description

  after_create :fetch_video_details

  has_many :projekt_questions, dependent: :destroy

  scope :sort_by_all, -> {
    all
  }

  def self.scoped_projekt_ids_for_footer(projekt)
    projekt.top_parent.all_children_projekts.unshift(projekt.top_parent).ids
  end

  def extract_video_platform
    if url.include?("youtube")
      :youtube
    elsif url.include?("vimeo")
      :vimeo
    end
  end

  def assign_video_platform
    if url_changed?
      self.video_platform = extract_video_platform
    end
  end

  def from_youtube?
    video_platform == "youtube"
  end

  def from_vimeo?
    video_platform == "vimeo"
  end

  def platform_formated
    case video_platform
    when "youtube"
      "YouTube"
    when "vimeo"
      "Vimeo"
    end
  end

  def assign_external_id
    if url_changed?
      self.external_id =
        case extract_video_platform
        when :youtube
          url.match(/v\=(?<youtube_id>\w+)/)[:youtube_id]
        when :vimeo
          url.match(/vimeo\.com\/(?<vimeo_id>\w+)/)[:vimeo_id]
        end
    end
  end

  def fetch_video_details
    if from_youtube?
      youtube_api = YoutubeApi.new(Rails.application.secrets.youtube_api_key)

      video_data = youtube_api.fetch_video(external_id)
      base_video_data = video_data["snippet"]

      if title.blank?
        self.title = base_video_data["title"]
      end

      if description.blank?
        self.description = base_video_data["description"]
      end

      if starts_at.blank?
        self.starts_at =
          if video_data["liveStreamingDetails"].present?
            video_data["liveStreamingDetails"]["scheduledStartTime"]
          else
            base_video_data["publishedAt"]
          end
      end
    elsif from_vimeo?
      vimeo_api = VimeoApi.new
      video_data = vimeo_api.fetch_video(url)

      if title.blank?
        self.title = video_data["title"]
      end

      if description.blank?
        self.description = video_data["description"]
      end

      if starts_at.blank?
        self.starts_at = video_data["upload_date"]
      end

      self.preview_image_url = video_data["thumbnail_url"]
    end

    save!
  rescue StandardError
  end

  def strip_description
    self.description = description&.strip
  end
end
