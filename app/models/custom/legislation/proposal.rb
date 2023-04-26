require_dependency Rails.root.join("app", "models", "legislation", "proposal").to_s

class Legislation::Proposal < ApplicationRecord
  # validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
  validates :terms_data_storage, acceptance: { allow_nil: false }, on: :create #custom
  validates :terms_data_protection, acceptance: { allow_nil: false }, on: :create #custom
  validates :terms_general, acceptance: { allow_nil: false }, on: :create #custom
end
