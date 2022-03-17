require_dependency Rails.root.join("app", "controllers", "moderation", "comments_controller").to_s

class Moderation::CommentsController < Moderation::BaseController
  has_filters %w[all unseen seen], only: :index
end
