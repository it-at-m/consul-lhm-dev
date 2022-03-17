require_dependency Rails.root.join("app", "controllers", "moderation", "budgets", "investments_controller").to_s

class Moderation::Budgets::InvestmentsController < Moderation::BaseController
  has_filters %w[all unseen seen], only: :index
end
