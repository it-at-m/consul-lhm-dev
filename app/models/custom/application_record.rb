require_dependency Rails.root.join("app", "models", "application_record").to_s

class ApplicationRecord < ActiveRecord::Base
  def comments_allowed?(user)
    true
  end
end
