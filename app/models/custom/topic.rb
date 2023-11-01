require_dependency Rails.root.join("app", "models", "topic").to_s

class Topic < ApplicationRecord
  def comments_allowed?(user)
    true
  end

  def on_behalf_of
    nil
  end

  def author_name
    author.name
  end
end
