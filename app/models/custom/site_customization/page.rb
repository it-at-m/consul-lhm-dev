require_dependency Rails.root.join("app", "models", "site_customization", "page").to_s

class SiteCustomization::Page < ApplicationRecord
  belongs_to :projekt

  has_many :comments, through: :projekt

  def draft?
    status == 'draft'
  end

  def published?
    status == 'published'
  end

  def comments_count
    comments.count
  end

  def full_url
    Setting['url'].chomp('/') + "/#{slug}"
  end
end
