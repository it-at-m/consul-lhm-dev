require_dependency Rails.root.join("app", "models", "legislation", "annotation").to_s

class Legislation::Annotation < ApplicationRecord
  delegate :projekt_phase, :permission_problem, :comments_allowed?, to: :draft_version
  alias_attribute :legislation_phase, :projekt_phase

  def create_first_comment
    annotation_comment = comments.create(body: text, user: author)
    NotificationServices::NewCommentNotifier.call(annotation_comment.id) if annotation_comment.persisted?
  end
end
