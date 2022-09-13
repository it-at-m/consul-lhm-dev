require_dependency Rails.root.join("app", "controllers", "moderation", "proposals_controller").to_s

class Moderation::ProposalsController < Moderation::BaseController
  has_filters %w[all unseen seen], only: :index
end
