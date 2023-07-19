require_dependency Rails.root.join("app", "models", "legislation", "proposal").to_s

class Legislation::Proposal < ApplicationRecord
  # validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
  validates :resource_terms, acceptance: { allow_nil: false }, on: :create #custom
end
