module Sentimentable
  extend ActiveSupport::Concern

  included do
    belongs_to :sentiment
    validates :sentiment_id, presence: true, on: :create, if: :sentiments_available?
  end

  def sentiments_available?
    return false if projekt_phase&.nil?

    projekt_phase.sentiments.exists?
  end
end
