require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord

  before_create :set_default_privacy_settings_to_false, if: :gdpr_conformity?

  def gdpr_conformity?
    Setting["extended_feature.gdpr_conformity"].present?
  end

  def set_default_privacy_settings_to_false
    self.public_activity = false
    self.public_interests = false
    self.email_on_comment = false
    self.email_on_comment_reply = false
    self.newsletter = false
    self.email_digest = false
    self.email_on_direct_message = false
  end
end
