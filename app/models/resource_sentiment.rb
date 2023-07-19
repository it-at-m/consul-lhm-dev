class ResourceSentiment < ApplicationRecord
  belongs_to :sentiment
  belongs_to :sentimentable, polymorphic: true
end
