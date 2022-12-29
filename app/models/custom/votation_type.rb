require_dependency Rails.root.join("app", "models", "votation_type").to_s

class VotationType < ApplicationRecord
  enum vote_type: %w[unique multiple rating_scale]
end
