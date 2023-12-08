class Poll::Question::Answer::Video < ApplicationRecord
  belongs_to :answer, class_name: "Poll::Question::Answer"

  VIMEO_REGEX = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/.freeze
  YOUTUBE_REGEX = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/.freeze

  validates :title, presence: true
  validate :valid_url?

  def self.model_name
    mname = super
    mname.instance_variable_set(:@route_key, "videos")
    mname.instance_variable_set(:@singular_route_key, "video")
    mname
  end

  def valid_url?
    return if url.blank?
    return if url.match(VIMEO_REGEX)
    return if url.match(YOUTUBE_REGEX)

    errors.add(:url, :invalid)
  end
end
