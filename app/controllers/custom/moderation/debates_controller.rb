require_dependency Rails.root.join("app", "controllers", "moderation", "debates_controller").to_s

class Moderation::DebatesController < Moderation::BaseController
  has_filters %w[all unseen seen], only: :index
end
