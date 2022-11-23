require_dependency Rails.root.join("app", "models", "legislation", "draft_version").to_s

class Legislation::DraftVersion < ApplicationRecord
  delegate :projekt, :legislation_phase, to: :process
end
