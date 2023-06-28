module Sentimentable
  extend ActiveSupport::Concern

  included do
    has_many :resource_sentiments, as: :sentimentable, dependent: :destroy
    has_many :sentiments, through: :resource_sentiments

    # validates :sentiments, presence: true, on: :create, if: :sentiments_available?
  end

  def sentiments_available?
    return false if projekt_phase&.nil?

    projekt_phase.sentiments.exists?
  end
end
